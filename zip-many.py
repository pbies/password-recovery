import os
import zipfile
import re
from tqdm import tqdm

zip_files = [name for name in os.listdir(".") if re.match(r'.*\.zip$',name)]

for zip_file in zip_files:
	print("File:", zip_file)
	zip_file = zipfile.ZipFile(zip_file)
	wordlist = "passwords.txt"
	n_words = len(list(open(wordlist, "rb")))
	print("Total passwords to test:", n_words)

	with open(wordlist, "rb") as wordlist:
		for word in tqdm(wordlist, total=n_words, unit="passwords"):
			try:
				zip_file.extractall(path='extracted',pwd=word.strip())
			except:
				continue
			else:
				print("[+] Password found:", word.decode().strip())
				break

print('Press Enter to quit...')
input()
