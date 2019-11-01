import boto3
import base64
import os
import argparse


def lambda_handler(region_name,keyID,passphrase):
    client = boto3.client('kms', region_name=region_name)
    response = client.encrypt(
    KeyId=f"alias/{keyID}",
    Plaintext= passphrase
    )

    ciphertext = response['CiphertextBlob']
    return base64.b64encode(ciphertext)


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='Process some integers.')
	parser.add_argument('--region')
	parser.add_argument('--keyID')
	parser.add_argument('--passphrase')

	args = parser.parse_args()
	print(lambda_handler(region_name = args.region,keyID = args.keyID,passphrase=args.passphrase))

