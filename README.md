# password_manager_demo
This is used for store the password of any account.

Login Screen
<img width="1865" height="863" alt="image" src="https://github.com/user-attachments/assets/0b4cfc33-9df0-4b15-a986-330635d426d6" />

OTP Verification Screen 
<img width="1894" height="708" alt="image" src="https://github.com/user-attachments/assets/27b7a6e6-fc47-4397-b459-945173e784ca" />

Vault Screen (Password List)
<img width="1875" height="909" alt="image" src="https://github.com/user-attachments/assets/5d937da2-3ab1-4deb-af23-9771f0b77ea0" />


Ths login use two factor verification process: (Node.js + Express)
1) Let user log in/register by using their email and master password. (password is hashed using bcrypt) (User account Information will be stored in mongoDB)
2) System send OTP (One Time Password) if email and password correct.
3) Verify OTP Correct or not?
4) Issue JWT Token for authentication process.


For vault screen (password list):
Load passwords:	Fetch saved passwords from service
Search:	Filter passwords by title/username/category
Add/Edit/Delete:	Manage stored passwords easily
Generate password:	Create strong random passwords
Favorites:	Mark important logins
User feedback:	SnackBars for success/error
