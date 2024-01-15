resource "aws_instance" "web" {
  ami           = "ami-0d3f444bc76de0a79"
  instance_type = "t2.micro"

  tags = {
    Name = "MyInstance"
  }
#   count = 10
}

resource "aws_key_pair" "key" {
  key_name   = "my-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCeq3qYBDKdyCsZARDrJPd0nDkFU+lFURGmLG7Pu24YCOIejOpcwYaROGUZDuz9WzO0kYbzRIVWJ87sa72Yvxn421hN0CpLFc6Rv0ZI+y9LA6/yzhEee6Tfpr94zP7rV8DSseyaAxBfLop7EB+iEjColD4XO8YabpmcjNFyC9bkNuGV+XoBUDaDE3wJm6RLm7GGkQad/nUpDn53/oYyQYJD2TFwUCBeJDyRoKR4XUl7AXRzwFs91AYUgwBCxhFNK4KjOIChUGXq3mxXZ9PWL9/V5GQrVHSSbjwrWnGYnjFM6shSjky45O94eB4r1PI7YygxxRtNJneU2GW+wC/OIaV/ZjlIrLiXE9hXd1oeaIxrWAm81h7lu/u7gEoWcC/4TTsKDckA/npZRBIYa7VPTS79SV779VX3KnErSA0J46BT4MXznZpis2uL8KMILrmuNPlqr70jGgyI9YYssuTChf2e5XVq/q2d6v24oVruS4t7CnyYU3eiqEoKLDu7vME4Ubc= ubuntu@ip-172-31-39-88"
}