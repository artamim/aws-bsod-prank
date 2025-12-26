import json
import boto3
import os

sns_client = boto3.client('sns')
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # Format the event message
    detail_type = event.get('detail-type', 'Unknown')
    detail = event.get('detail', {})
    asg_name = detail.get('AutoScalingGroupName', 'Unknown')
    instance_id = detail.get('EC2InstanceId', 'Unknown')
    lifecycle_action = detail.get('LifecycleActionToken', 'N/A')
    status = detail.get('LifecycleTransition', 'Unknown')

    message = f"""
ASG Event Notification:
- Event Type: {detail_type}
- Auto Scaling Group: {asg_name}
- Instance ID: {instance_id}
- Lifecycle Action: {lifecycle_action}
- Status: {status}
- Full Event Details: {json.dumps(event, indent=2)}
"""

    # Publish to SNS
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Message=message,
        Subject='BSOD ASG Instance Event'
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent successfully')
    }