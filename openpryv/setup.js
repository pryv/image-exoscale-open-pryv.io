let fs = require('fs');
const { execSync } = require("child_process");

const netplanPath = '/etc/netplan/51-eip.yaml';
const nginxPath = '/etc/nginx/sites-enabled/default';
const configPath = '/home/ubuntu/open-pryv.io/config.json';

const setupCmd = `
mv /home/ubuntu/51-eip.yaml `+ netplanPath + `;
mv /home/ubuntu/default ` + nginxPath + `;
mv /home/ubuntu/config.json ` + configPath + `;
mv /home/ubuntu/openpryv.sh /usr/bin/openpryv.sh;
chmod +x /usr/bin/openpryv.sh;
mv /home/ubuntu/openpryv.service /etc/systemd/system/openpryv.service;
chmod 644 /etc/systemd/system/openpryv.service;
`;

execSync(setupCmd);

let confFile = JSON.parse(fs.readFileSync('/tmp/conf/config.json', 'utf8'));
let userNet = fs.readFileSync(netplanPath, 'utf8');
let config = fs.readFileSync(configPath, 'utf8');
let nginx = fs.readFileSync(nginxPath, 'utf8');
const regexDomain = /\${DOMAIN}/gi;
const regexIP = /\${IP_ADDRESS}/gi;
const regexKey = /\${RANDOM_KEY}/gi;

userNet = userNet.replace(regexIP, confFile.IP);
fs.writeFileSync(netplanPath, userNet);

config = config.replace(regexDomain, confFile.DOMAIN);
config = config.replace(regexKey, confFile.KEY);
fs.writeFileSync(configPath, config);

nginx = nginx.replace(regexDomain, confFile.DOMAIN);
fs.writeFileSync(nginxPath, nginx);

const cmd = `
netplan apply;
while ! ping -q -c 1 ` + confFile.IP + `>/dev/null ; do sleep 1; done ;
certbot --nginx -n --email `+ confFile.EMAIL + ` --agree-tos -d ` + confFile.DOMAIN + `;
echo "0 1 * * * root certbot renew" >> /etc/crontab;
service nginx restart;
git -C /home/ubuntu/open-pryv.io/ config user.email "`+ confFile.EMAIL + `";
systemctl enable openpryv.service;
systemctl start openpryv.service;
`

execSync(cmd);