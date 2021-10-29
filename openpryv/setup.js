let fs = require('fs');
const { execSync } = require("child_process");

const nginxPath = '/etc/nginx/sites-enabled/default';

const pryvBasePath = '/var/pryv';
const pryvPath = pryvBasePath + '/open-pryv.io';
const logFile = '/home/ubuntu/setup.log';

log('Fetch new version of Open-Pryv.io');
execSync(`git -C ${pryvBasePath} clone https://github.com/pryv/open-pryv.io.git  >> ${logFile} 2>&1`);

log('Setup Dev environement of Open-Pryv.io');
execSync(`yes | yarn --cwd ${pryvPath} setup  >> ${logFile} 2>&1`);

log('Build Open-Pryv.io');
execSync(`yes | yarn --cwd ${pryvPath} release  >> ${logFile} 2>&1`);

const setupCmd = `
mv /home/ubuntu/default ` + nginxPath + `;
mv /home/ubuntu/config.yml ` + pryvPath + `/config.yml;
mv /home/ubuntu/openpryv.sh /usr/bin/openpryv.sh;
chmod +x /usr/bin/openpryv.sh;
mv /home/ubuntu/openpryv.service /etc/systemd/system/openpryv.service;
chmod 644 /etc/systemd/system/openpryv.service;
`;

execSync(setupCmd + ` >> ${logFile}`);
log("Copy files and modify permissions")

let confFile = JSON.parse(fs.readFileSync('/tmp/conf/config.json', 'utf8'));
let config = fs.readFileSync(pryvPath + "/config.yml", 'utf8');
let nginx = fs.readFileSync(nginxPath, 'utf8');
const regexHostname = /\${HOSTNAME}/gi;
const regexKey = /\${RANDOM_KEY}/gi;

config = config.replace(regexHostname, confFile.HOSTNAME);
config = config.replace(regexKey, confFile.KEY);
fs.writeFileSync(pryvPath + "/config.yml", config);
log("Modify " + pryvPath + "/config.yml");

nginx = nginx.replace(regexHostname, confFile.HOSTNAME);
fs.writeFileSync(nginxPath, nginx);
log("Modify " + nginxPath);

log("Start Open-Pryv.io service")
const cmdService = `
systemctl enable openpryv.service;
systemctl start openpryv.service;
`
execSync(cmdService);

log("Start to wait for DNS A record")
let host = -1;
let record = 0;
while (host != record) {
    log(`Wait ... for DNS to resolve ${confFile.HOSTNAME}`);
    if (host !== -1) {
        execSync(`sleep 10`);
    }
    host = execSync(`hostname -i | awk '{print $1}'`).toString();
    record = execSync(`dig @8.8.8.8 ${confFile.HOSTNAME} +short`).toString(); //@8.8.8.8 to force to refresh cache
}

log("DNS record set")
log("Start Letsencrypt")
const cmdCert = `
certbot --nginx -n --email ${confFile.EMAIL} --agree-tos -d ${confFile.HOSTNAME};
echo "0 1 * * * root certbot renew" >> /etc/crontab;
service nginx restart;
`
execSync(cmdCert);
log("Letsencrypt done");
log("setup done!")


function log(info) {
    const date = new Date();
    execSync(`echo "########## ${date.toUTCString()} ${info} ##########" >> ${logFile}`)
}

