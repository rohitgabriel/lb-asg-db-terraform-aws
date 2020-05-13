
# // Create a new secret with the password passed in as variable, this is set as the DB password 
# resource "aws_secretsmanager_secret" "TestAppSecret" {
#   name        = "dev/testappdatabase5"
#   description = "postgres credentials"
#   #   rotation_rules {
#   #     automatically_after_days = 7
#   #   }
# }

# resource "aws_secretsmanager_secret_version" "TestAppCredentials" {
#   secret_id     = aws_secretsmanager_secret.TestAppSecret.id
#   secret_string = "{\"username\":\"postgres\",\"password\":\"random_string.dbpass.result\"}"
# }

# data "aws_secretsmanager_secret_version" "by-version-stage" {
#   secret_id  = aws_secretsmanager_secret.TestAppSecret.id
#   depends_on = [module.db]
# }