# node-app
# $ curl 127.0.0.1:3000/
# Hello, World!

# docker build -t node-app:1.0 .
# docker run -d -p 3000:3000 my-node:1.0
# docker tag node-app:1.0 chesnokov70/node-app:1.0
# docker login
# docker push chesnokov70/node-app:1.0
# docker compose up -d --build
# docker compose down
# docker exec -it node-app-nginx sh
# cat /etc/timezone
# America/New_York
#-----------------------------
# docker exec -it jenkins bash
# rm -rf /var/jenkins_home/jobs/*/builds
# scp /var/lib/jenkins/workspace/My_Lessons_Folder/node-app/docker-compose.tmpl root@${HOST}:/opt
# scp /var/lib/jenkins/workspace/My_Lessons_Folder/node-app/promtail-config.yaml root@${HOST}:/opt 
# rsync /var/lib/jenkins/workspace/My_Lessons_Folder/node-app/ root@${HOST}:/node-app