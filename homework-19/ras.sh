 #!/bin/bash
  setenforce 0
  cd /etc/openvpn 
  /usr/share/easy-rsa/3.0.6/easyrsa init-pki   
  echo 'rasvpn' | /usr/share/easy-rsa/3.0.6/easyrsa build-ca nopass
  echo 'rasvpn' | /usr/share/easy-rsa/3.0.6/easyrsa gen-req server nopass
  echo 'yes' | /usr/share/easy-rsa/3.0.6/easyrsa sign-req server server
  /usr/share/easy-rsa/3.0.6/easyrsa gen-dh
  openvpn --genkey --secret ta.key
  echo 'client' | /usr/share/easy-rsa/3.0.6/easyrsa gen-req client nopass
  echo 'yes' | /usr/share/easy-rsa/3.0.6/easyrsa sign-req client client
  echo 'iroute 192.168.33.0 255.255.255.0' > /etc/openvpn/client/client
  ln -s /vagrant/ras.conf /etc/openvpn/server.conf
  systemctl start openvpn@server
  systemctl enable openvpn@server
  cp /etc/openvpn/pki/ca.crt /tmp/
  cp /etc/openvpn/pki/private/client.key /tmp/
  cp /etc/openvpn/pki/issued/client.crt /tmp/
  chown -R vagrant:vagrant /tmp/c*