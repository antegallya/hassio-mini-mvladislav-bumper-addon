# Home Assistant Add-on: mini MVladislav's Ecovax Bumper

A Hassio add-on for a minimal version of MVladislav's Ecovacs Bumper (https://github.com/MVladislav/bumper).

This add-on only serves the Bumper part. The Nginx server is not included. Proxying is supposed to be handled elsewhere.

## Setup
Certificates are to be put in `/addon_configs/{REPO}_bumper/certs/`, where `{REPO}` will be `local` or, `ac77692b` (you can check that on the add-on page in Home Assistant). See https://github.com/MVladislav/bumper for details on how to generate certificates.

Bumper internally listens to 443, 1883, 5223, 8007, but none are exposed to the host. This is expected to be handled by a reverse proxy, with SSL SNI support, which is required to be set up. Essentially, it needs to map some domains on bumper's HTTPS and some on MQTTS:
```nginx configuration
    map $ssl_preread_server_name $final_port {
        ~^.*(mq).*\.eco(vacs|user)\.(net|com)$    8883; # MQTTS
        ~^.*(mq).*\.aliyuncs\.(com)$              8883; # MQTTS
        ~^.*eco(vacs|user)\.(net|com)$             443; # HTTPS
        ~^.*aliyuncs\.com$                         443; # HTTPS
        ~^.*aliyun\.com$                           443; # HTTPS
        default                                   8883; # MQTTS
    }
    server {
        listen 443;
        ssl_preread  on;
        proxy_pass ac77692b_bumper:$final_port;
    }
```

The hostname `ac77692b_number` is the add-on hostname, as explained above (e.g.: `local_bumper`).

The default redirects to MQTTS, because the robot will contact bumper on 443 **by IP**. That means that there's no SNI to discriminate there. If we're using the same IP for Bumper and Home Assistant, we could still discriminate by domain, as Home Assistant clients will use the server name to connect. 

Another option is to map on the client IP (robot or something else), together with the server name.

And another option is to use a different IP for Bumper and Home Assistant, maybe a have a reverse proxy on a dedicated "Bumper IP". The main problem here is that Home Assistant OS supports multiple IPs, but all the default add-ons are configured to listen on all of them. We can control. The nginx proxy will need to handle redirecting the frontend HTTP, HTTPS, websockets and mosquito MQTT.