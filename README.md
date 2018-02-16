# dp-compose-web-tests

A docker compose project for running dp-web-tests

To run the tests you will need docker installed on your machine.
It it is recommended that you adjust your docker preferences to provision with
6GB memory and 5CPUs.

### Environment variables

You will need to have the following environment variables set correctly to run the web tests:

- export AWS_ACCESS_KEY_ID=
- export AWS_SECRET_ACCESS_KEY=

Once this is completed you can simply run the tests using the run script:

`./run.sh`
