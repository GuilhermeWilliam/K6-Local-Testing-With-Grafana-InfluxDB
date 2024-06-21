# docker-k6-grafana-influxdb

Demonstrates how to run load tests with containerized instances of K6, Grafana, and InfluxDB.

#### To Run Project

1. **Build the Custom K6 Image**:
   ```sh
   docker-compose build

2. **Start InfluxDB and Grafana**:
   ```sh
   docker-compose up -d influxdb grafana

3. **Run the k6 Test**:
    ```sh
    docker-compose run k6 run /scripts/stress-test.js


### Grafana Url
http://localhost:3000/

### Influx DB Url 
http://localhost:8086/



#### Dashboards
The dashboard in /dashboards is adapted from the excellent K6 / Grafana dashboard here:
https://grafana.com/grafana/dashboards/2587

There are only two small modifications:
* The data source is configured to use the Docker-created InfluxDB data source.
* The time period is set to now-15m, which I feel is a better view for most tests.

#### Scripts
The script here is an example of a low Virtual User (VU) load test of the excellent Star Wars API:
https://swapi.dev/

If you're tinkering with the script, it is just a friendly open source API, be gentle!

### Example test script:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

const isNumeric = (value) => /^\d+$/.test(value);
const default_vus = 5;
const target_vus_env = `${__ENV.TARGET_VUS}`;
const target_vus = isNumeric(target_vus_env) ? Number(target_vus_env) : default_vus;

export let options = {
stages: [
 { duration: '15s', target: target_vus },
 { duration: '20s', target: target_vus },
 { duration: '5s', target: 0 }
],
insecureSkipTLSVerify: true
};

export default function () {
const response = http.get('https://swapi.dev/api/people/30/', {
 headers: { Accepts: 'application/json' }
});
check(response, { 'status is 200': (r) => r.status === 200 });
sleep(0.3);
};