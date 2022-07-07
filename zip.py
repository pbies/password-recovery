import zipfile
from tqdm import tqdm

wordlist = "passwords.txt"
zip_file = "archive.zip"

zip_file = zipfile.ZipFile(zip_file)
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
