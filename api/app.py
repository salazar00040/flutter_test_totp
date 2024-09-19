import pyotp
import logging
from flask import Flask, request, jsonify

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = Flask(__name__)

# Dummy credentials for example
USER_CREDENTIALS = {
    "admin": {
        "password": "password123",
        "totp_secret": pyotp.random_base32()  # Generate a new base32 secret for TOTP
    }
}

VALID_RECOVERY_CODE = "000010"  # Special code to bypass TOTP verification

@app.route('/auth/login', methods=['POST'])
def login():
    data = request.json
    username = data.get("username")
    password = data.get("password")
    totp_code = data.get("totp_code")

    logging.info(f"Login attempt for username: {username}")

    # Check if the username exists and password is correct
    if username in USER_CREDENTIALS and password == USER_CREDENTIALS[username]["password"]:
        # Verify the TOTP code
        logging.info(f"Username '{username}' provided correct password.")
        totp = pyotp.TOTP(USER_CREDENTIALS[username]["totp_secret"])
        if totp.verify(totp_code):
            logging.info(f"TOTP code for username '{username}' verified successfully.")
            response = {
                "message": "Login successful",
                "status": "success"
            }
            return jsonify(response), 200  # Successful login
        else:
            logging.warning(f"TOTP code for username '{username}' is invalid.")
            logging.warning(f"TOTP input: {totp_code}, TOTP expected: {totp.now()}")
            response = {
                "message": "Invalid TOTP code",
                "status": "failure"
            }
            return jsonify(response), 401  # TOTP verification failed
    else:
        logging.warning(f"Invalid credentials for username '{username}'.")
        response = {
            "message": "Invalid credentials",
            "status": "failure"
        }
        return jsonify(response), 401  # Invalid credentials

@app.route('/auth/recovery-secret', methods=['POST'])
def get_seed():
    data = request.json
    username = data.get("username")
    password = data.get("password")
    code = data.get("code")

    logging.info(f"Recovery secret attempt for username: {username} with code: {code}")

    # Check if the user exists
    if username in USER_CREDENTIALS:
        # Check if the password is correct
        if password == USER_CREDENTIALS[username]["password"]:
            # Special check for the code '000010'
            if code == VALID_RECOVERY_CODE:
                logging.info(f"Recovery code verified for username '{username}'.")
                logging.info(f"TOTP secret for username '{username}': {USER_CREDENTIALS[username]['totp_secret']}")
                response = {
                    "message": "Recovery code and password verified",
                    "totp_secret": USER_CREDENTIALS[username]["totp_secret"]
                }
                return jsonify(response), 200  # Return the secret if the code is 000010
            else:
                logging.warning(f"Invalid recovery code for username '{username}'.")
                response = {
                    "message": "Invalid recovery code"
                }
                return jsonify(response), 401  # Invalid recovery code
        else:
            logging.warning(f"Incorrect password for username '{username}'.")
            response = {
                "message": "Invalid password"
            }
            return jsonify(response), 401  # Incorrect password
    else:
        logging.warning(f"Username '{username}' not found for recovery.")
        response = {
            "message": "User not found"
        }
        return jsonify(response), 404  # User not found


if __name__ == '__main__':
    logging.info("Starting Flask server...")
    app.run(debug=True)