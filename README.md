# Netservate

Netservate is a simple ruby program that runs network speed tests, logs the results, and notifies the user through email when the results don't meet a given criteria.

## Installation

For now, you can download Netservate by cloning from the GitHub repo or
by downloading the zip file using the green "Clone or download" button on
the main GitHub page. Once you have it downloaded and unzipped in the directory
of your choosing, you can begin the installation process.

First, open a terminal and check if ruby is installed on your system:

```
ruby -v
```

If not, install with RVM (https://rvm.io/rvm/install) or using:

```
apt-get install ruby
```
If you receive an error regarding permissions, you may need to add `sudo` before your
commands.

Once ruby is installed, download Netservate, unzip if necessary, and use the following commands to do the initial setup:

```
cd path/to/netservate/bin
./setup
```

This installs all of the necessary dependencies to run the program.

## Configuration

If you used `./setup` you will be asked if you want to configure Netservate:

```
Would you like to configure Netservate? (Y/N):
```
If you said no, you can choose to configure Netservate later using:
```
cd path/to/netservate/bin
./config
```
Alternatively - you can edit the config file itself `netservate/config/netservate.conf`

### Email Settings

Netservate uses SMTP to send email alerts. In order to use this feature, you
must have your email settings set. You can use any SMTP solution. We recommend
setting up a MailJet account (https://www.mailjet.com/). If you use MailJet, you
can easily go to (https://app.mailjet.com/account/setup) and use the settings
they provide.

#### Server Name

```
Enter your server name. Ex: in-v3.mailjet.com
Netservate uses SMTP to send email.
SERVER NAME:
```

#### Server Port

```
Enter your server port. Ex: 587
PORT:
```

#### Username

```
Enter your username for the server.
USERNAME:
```

#### Password

```
Enter your password for the server.
PASSWORD:
```

#### Origin and Destination Email Addresses

```
Set up who sends and receives email alerts. Origin and destination.
If you are sending mail to yourself, you can use the same address.
ORIGIN ADDRESS:
DESTINATION ADDRESS:
```
Currently we only support one destination email address.

### Netservate Settings

The Netservate settings are where you set your test and alert parameters. All of
these settings have defaults - though you may want to change them to fit your needs.

#### Minimum Download Rate

```
What is your minimum acceptable download rate (in Mbps)?
Current: 25.0
MIN DOWNLOAD:
```

#### Minimum Upload Rate

```
What is your minimum acceptable upload rate (in Mbps)?
Current: 3.0
MIN UPLOAD:
```

#### Test Interval

You can set the amount of time between each network test. By default, tests are
run every 15 minutes (900 seconds).
```
How often should Netservate typically run network tests (in seconds)?
Current: 900
TEST INTERVAL:
```

#### Time After Failed Tests

When a test does not meet your minimum download and upload requirements, it fails.
Failed tests don't always mean your network has slowed down, so its good to run
another test soon after to check. By default, if a test has failed, we wait 60 seconds
before running the next test. If it fails again, we keep running tests to monitor the
situation.

```
If a test fails, how long should the wait be before the next one (in seconds)?
Current: 60
TIME AFTER FAIL:
```

#### Fails In A Row Before Alerting

If failed tests continue, this setting determines how many failed tests should occur
in a row before sending an email alert. By default, alerts are sent every 5 failed tests.
With this setting, 10 failed tests in a row will result in 2 emails.

```
How many tests should fail in a row before an email is sent?
Current: 5
FAILS IN A ROW:
```

#### Maximum Fails In A Row

If tests continue to fail, it can be annoying to keep receiving alerts. This setting
allows you to set the maximum number of failed tests in a row you want to be
alerted about. By default this is set to 20. Keep in mind - tests will continue to
run and log data.

```
If tests continue to fail...
What is the maximum number of failures you want to be notified about?
(Emails will stop being sent if this number is surpassed.)
Current: 20
MAX FAILS IN A ROW:
```

## Usage

### Run

To start Netservate, open a terminal and execute the run file:

```
cd path/to/netservate/bin
./run
```

Netservate can be stopped using `Ctrl-C`.

### Logs

Logs can be found in `path/to/netservate/log/netservate.log`

## Updating

You can download new updates from GitHub at anytime. If you do - be sure to save
your config folder and replace the default config with your own, unless you want
to walk through the config process again.
