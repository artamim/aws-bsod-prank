resource "aws_sns_topic" "asg_notifications" {
  name = "BSOD-ASG-Notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.asg_notifications.arn
  protocol  = "email"
  endpoint  = "artamim22@gmail.com" # Replace with your actual Gmail address
}