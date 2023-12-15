
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
    cat <<EOF > /var/www/html/index.html
    "welcome ubuntu"
       EOF 