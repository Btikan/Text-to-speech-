import os
import json
import uuid
import logging
import boto3
from botocore.exceptions import BotoCoreError, ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

polly = boto3.client('polly')
s3 = boto3.client('s3')

AUDIO_BUCKET = os.environ.get('AUDIO_BUCKET')
MAX_POLLY_CHARS = 3000  # Polly limit (approx). For production, chunk or use SSML.

ALLOWED_FORMATS = ['mp3', 'ogg_vorbis', 'pcm']
ALLOWED_VOICES = [
    'Joanna', 'Matthew', 'Ivy', 'Justin', 'Kendra', 'Joey', 'Nicole'
]


def make_response(status_code, body_dict):
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, OPTIONS'
        },
        'body': json.dumps(body_dict)
    }


def lambda_handler(event, context):
    try:
        method = event.get("requestContext", {}).get("http", {}).get("method")

        # Handle CORS preflight
        if method == "OPTIONS":
            return make_response(200, {"message": "CORS preflight OK"})

        # Parse body
        body = {}
        if event.get('body'):
            try:
                body = json.loads(event['body'])
            except Exception:
                body = {}
        elif event.get('queryStringParameters'):
            body = event.get('queryStringParameters') or {}

        text = (body.get('text') or '').strip()
        voice = body.get('voice', 'Joanna')
        fmt = body.get('format', 'mp3')

        if not text:
            return make_response(400, {'error': 'Missing `text` in request body'})

        if len(text) > MAX_POLLY_CHARS:
            return make_response(400, {'error': f'Text too long. Limit to {MAX_POLLY_CHARS} characters for now.'})

        if fmt not in ALLOWED_FORMATS:
            return make_response(400, {'error': f'Unsupported format. Choose one of {ALLOWED_FORMATS}'})

        if voice not in ALLOWED_VOICES:
            logger.info(f'Voice \"{voice}\" not in allowed list — attempting request anyway')

        # Call Polly
        response = polly.synthesize_speech(
            Text=text,
            OutputFormat=fmt,
            VoiceId=voice
        )

        if 'AudioStream' not in response:
            return make_response(500, {'error': 'Polly did not return an audio stream'})

        audio_bytes = response['AudioStream'].read()

        # Generate unique key
        key = f"tts/{uuid.uuid4()}.{fmt}"

        # Upload to S3
        s3.put_object(
            Bucket=AUDIO_BUCKET,
            Key=key,
            Body=audio_bytes,
            ContentType='audio/mpeg' if fmt == 'mp3' else 'audio/ogg'
        )

        # Generate presigned URL (valid 1 hour)
        presigned = s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': AUDIO_BUCKET, 'Key': key},
            ExpiresIn=3600
        )

        return make_response(200, {'url': presigned, 'key': key})

    except (BotoCoreError, ClientError) as e:
        logger.exception('AWS client error')
        return make_response(500, {'error': 'AWS error', 'detail': str(e)})
    except Exception as e:
        logger.exception('Unhandled error')
        return make_response(500, {'error': 'Unhandled error', 'detail': str(e)})
