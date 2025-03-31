# Self Hosting SimpleFIN to Maybe with Docker

## Installation

### Step 1: Configure Docker Compose file and environment

#### Create a directory for your app to run

Open your terminal and create a directory where your app will run. Below is an example command with a recommended directory:

```bash
# Create a directory on your computer for Docker files (name whatever you'd like)
mkdir -p ~/simplefin_to_maybe

# Once created, navigate your current working directory to the new folder
cd ~/simplefin_to_maybe
```

#### Copy the sample Docker Compose file

Make sure you are in the directory you just created and run the following command:

```bash
# Download the sample compose.yml file from the Github repository
curl -o docker-compose.yml https://raw.githubusercontent.com/steveredden/simplefin_to_maybe/main/docker-compose.yml
```

This command will do the following:

1. Fetch the sample docker compose file from the public Github repository
2. Creates a file in your current directory called `docker-compose.yml` with the contents of the example file

At this point, the only file in your current working directory should be `compose.yml`.

### Step 3 : Configure your environment

In order to configure the app, you will need to create a file called `.env`, which is where Docker will read environment variables from.

To do this, run the following command:

```bash
touch .env
```

#### Generate the app secret key

The app requires an environment variable called `SECRET_KEY_BASE` to run.

We will first need to generate this in the terminal. If you have `openssl` installed on your computer, you can generate it with the following command:

```bash
openssl rand -hex 64
```

_Alternatively_, you can generate a key without openssl or any external dependencies by pasting the following bash command in your terminal and running it:

```bash
head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n' && echo
```

Once you have generated a key, save it and move on to the next step.

#### Fill in your environment file

Open the file named `.env` that we created in a prior step using your favorite text editor.

Update this file's keys with appropriate values, example:

```txt
SECRET_KEY_BASE="replacemewiththegeneratedstringfromthepriorstep"
POSTGRES_PASSWORD="replacemewithyourdesireddatabasepassword"
```

### Step 4: Run the app

You are now ready to run the app. Start with the following command to make sure everything is working:

```bash
docker compose up
```

This will pull the Docker image and start the app. You will see logs in your terminal.

Open your browser, and navigate to `http://localhost:9501`.

If everything is working, you will see the SimpleFIN to Maybe home screen.

### Step 5: Application Configuration

Review the settings in the [Web App Configuration](config.md) readme.