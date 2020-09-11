let fs = require('fs');
const { execSync } = require("child_process");


const nginxPath = '/etc/nginx/sites-enabled/default';
const configPath = '/var/pryv/open-pryv.io/config.json';

const setupCmd = `
mv /home/ubuntu/default ` + nginxPath + `;
mv /home/ubuntu/config.json ` + configPath + `;
mv /home/ubuntu/openpryv.sh /usr/bin/openpryv.sh;
chmod +x /usr/bin/openpryv.sh;
mv /home/ubuntu/openpryv.service /etc/systemd/system/openpryv.service;
chmod 644 /etc/systemd/system/openpryv.service;
`;

execSync(setupCmd);

let confFile = JSON.parse(fs.readFileSync('/tmp/conf/config.json', 'utf8'));
let config = fs.readFileSync(configPath, 'utf8');
let nginx = fs.readFileSync(nginxPath, 'utf8');
const regexDomain = /\${DOMAIN}/gi;
const regexKey = /\${RANDOM_KEY}/gi;

config = config.replace(regexDomain, confFile.DOMAIN);
config = config.replace(regexKey, confFile.KEY);
fs.writeFileSync(configPath, config);

nginx = nginx.replace(regexDomain, confFile.DOMAIN);
fs.writeFileSync(nginxPath, nginx);

const cmdService = `
git -C /var/pryv/open-pryv.io/ config user.email "${confFile.DOMAIN}";
systemctl enable openpryv.service;
systemctl start openpryv.service;
`
execSync(cmdService);

let host = -1;
let record = 0;
while (host != record) {
    host = execSync(`hostname -i | awk '{print $1}'`).toString();
    record = execSync(`dig @8.8.8.8 ${confFile.DOMAIN} +short`).toString(); //@8.8.8.8 to force to refresh cache
}

const cmdCert = `
certbot --nginx -n --email ${confFile.EMAIL} --agree-tos -d ${confFile.DOMAIN};
echo "0 1 * * * root certbot renew" >> /etc/crontab;
service nginx restart;
`
execSync(cmdCert);
