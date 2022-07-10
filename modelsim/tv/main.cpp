//A C++ program to illustrate 2 stage Caesar Cipher Technique

#include <iostream>
#include <string>
#include <fstream>
using namespace std;

//This function receives text and shift and returns the encrypted text
string encrypt(string text,int d,int s1,int s2)
{
	string result="";
	int dir = d;
	char s;

	//left shift if dir == 0
	if(dir == 0)
        {
	//traverse text
	for(int i=0;i<text.length();i++)
	{
		//apply transformation to each character
		//Encrypt Uppercase letters
		if(isupper(text[i]))
		{
		    s = char(int(text[i]+s1-65)%26 +65);
		    s = char(int(s+s2-65)%26 +65);
			result+=s;
			continue;
		}

	//Encrypt Lowercase letters
	else if(islower(text[i])){
            s = char(int(text[i]+s1-97)%26 +97);
            s = char(int(s+s2-97)%26 +97);

		result+=s;
		continue;

	}
	else{
        result +=" ";
        continue;
	}
	//Return the resulting string
	return result;
    }
    }
    else if(dir == 1)
    {
       //traverse text
	for(int i=0;i<text.length();i++)
	{
		//apply transformation to each character
		//Encrypt Uppercase letters
		if(isupper(text[i]))
		{
		    s = char(int(text[i]-s1+65)%26 +65);
		    s = char(int(s-s2+65)%26 +65);

			result+=s;
			continue;
		}

	//Encrypt Lowercase letters
	else if(islower(text[i]))
	{
            int s3 = s2-2;
            s = char(int(text[i]-s1+97)%26 +97);
            s = char(int(s-s3+97)%26 +97);
		result+=s;
		continue;

	}
	else{
        result +=" ";
        continue;
	}
	//Return the resulting string
	return result;
    }
    }
}

//This function receives text and shift and returns the decrypted text
string decrypt(string text,int d,int s1,int s2)
{
	string result="";
	int dir = d;
	char s;

	//left shift if dir == 0
	if(dir == 1)
        {
	//traverse text
	for(int i=0;i<text.length();i++)
	{
		//apply transformation to each character
		//Encrypt Uppercase letters
		if(isupper(text[i]))
		{
		    s = char(int(text[i]+s1-65)%26 +65);
		    s = char(int(s+s2-65)%26 +65);
			result+=s;
			continue;
		}

	//Encrypt Lowercase letters
	else if(islower(text[i])){
            s = char(int(text[i]+s1-97)%26 +97);
            s = char(int(s+s2-97)%26 +97);

		result+=s;
		continue;

	}
	else{
        result +=" ";
        continue;
	}
	//Return the resulting string
	return result;
    }
    }
    else if(dir == 0)
    {
       //traverse text
	for(int i=0;i<text.length();i++)
	{
		//apply transformation to each character
		//Encrypt Uppercase letters
		if(isupper(text[i]))
		{
		    s = char(int(text[i]-s1+65)%26 +65);
		    s = char(int(s-s2+65)%26 +65);

			result+=s;
			continue;
		}

	//Encrypt Lowercase letters
	else if(islower(text[i]))
	{
            int s3 = s2-2;
            s = char(int(text[i]-s1+97)%26 +97);
            s = char(int(s-s3+97)%26 +97);
		result+=s;
		continue;

	}
	else{
        result +=" ";
        continue;
	}
	//Return the resulting string
	return result;
    }
    }
}
//Driver program to test the above function
int main()
{
   string text1="";
   string text2="";
	int s1 = 10;
	int s2 = 3;
	int d = 1; //right shift
	int s11 = 5;
	int s22 = 1;
	int d1 = 0; //left shift

    //read plaintext from ptx
    ifstream file("ptxt.txt");
    if(file.is_open())
    {
        while(getline(file,text1))
        {
            cout<<text1<<endl;
        }
        file.close();
    }
    else{
        cout<<"unable to open file";
    }

	cout<<"Text :"<<text1;
	cout<<"\nShift:" << s1;
	cout<<"\nShift:" << s2;
	s1 = s1%26; // ensuring that s lies between 0-25
	s2 = s2%26;
	s11 = s11%26;
	s22 = s22%26;

	//encrypt ptxt
	text1 = encrypt(text1,d, s1, s2);

    //write encrypted ptxt to enc.txt
	ofstream file1("enc.txt");
	if(file1.is_open())
    {
        file1<<text1;
        file1.close();
    }
	else{
        cout<<"File not open";
	}

	// Decrypting the enc.txt
	string dec="";
	ifstream file2("enc.txt");
	if(file2.is_open())
    {
        while(getline(file2,dec))
        {
            cout<<endl;
            cout<<"Encrypted ENC :"<<dec<<endl;
        }
        file2.close();
    }
    else{
        cout<<"File not open";
	}

    //calling the decryption function
    dec = decrypt(dec,d, s1, s2);
    cout<<dec<<endl;

    //saving the decryption to dec.txt
    ofstream file3("dec.txt");
	if(file3.is_open())
    {
        file3<<dec;
        file3.close();
    }
	else{
        cout<<"File not open";
	}


	//read plaintext of ptxt2.txt
	ifstream file4("ptxt2.txt");
    if(file4.is_open())
    {
        while(getline(file4,text2))
        {
            cout<<text2<<endl;
        }
        file4.close();
    }
    else{
        cout<<"unable to open file";
    }

    //encrypt ptxt2.txt
    text2 = encrypt(text2,d1, s11, s22);

    //save encrypted ptxt2 to enc2
    ofstream file5("enc2.txt");
	if(file5.is_open())
    {
        file5<<text2;
        file5.close();
    }
	else{
        cout<<"File not open";
	}

    // Decrypting the enc2.txt
	string dec2="";
	ifstream file6("enc2.txt");
	if(file6.is_open())
    {
        while(getline(file6,dec2))
        {
            cout<<endl;
            cout<<"Encrypted ENC2 :"<<dec2<<endl;
        }
        file6.close();
    }
    else{
        cout<<"File not open";
	}

    //calling the decryption function
    dec2 = decrypt(dec2,d1, s11, s22);
    cout<<dec2<<endl;

    //saving the decryption to dec2.txt
    ofstream file7("dec2.txt");
	if(file7.is_open())
    {
        file7<<dec2;
        file7.close();
    }
	else{
        cout<<"File not open";
	}

	return 0;
}

