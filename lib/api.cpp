#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <string.h>
#include <chrono>
#include <thread>
#include <time.h>
#include <fstream>
#include <vector>
#include <winreg.h>

#ifdef WIN32
   #define EXPORT __declspec(dllexport)
#else
   #define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

#define MAX_PORTS 10

using namespace std;

class SimpleSerial
{

private:
	HANDLE io_handler_;
	COMSTAT status_;
	DWORD errors_;

	string syntax_name_;
	char front_delimiter_;
	char end_delimiter_;

	void CustomSyntax(string syntax_type);

public:
	SimpleSerial(char* com_port, DWORD COM_BAUD_RATE);

	string ReadSerialPort(int reply_wait_time, string syntax_type);
	bool WriteSerialPort(char *data_sent);
	bool CloseSerialPort();
	~SimpleSerial();
	bool connected_;
};

SimpleSerial::SimpleSerial(char* com_port, DWORD COM_BAUD_RATE)
{
	connected_ = false;

	io_handler_ = CreateFileA(static_cast<LPCSTR>(com_port),
							GENERIC_READ | GENERIC_WRITE,
							0,
							NULL,
							OPEN_EXISTING,
							FILE_ATTRIBUTE_NORMAL,
							NULL);

	if (io_handler_ == INVALID_HANDLE_VALUE) {

		if (GetLastError() == ERROR_FILE_NOT_FOUND)
			printf("Warning: Handle was not attached. Reason: %s not available\n", com_port);
	}
	else {

		DCB dcbSerialParams = { 0 };

		if (!GetCommState(io_handler_, &dcbSerialParams)) {

			printf("Warning: Failed to get current serial params");
		}

		else {
			dcbSerialParams.BaudRate = COM_BAUD_RATE;
			dcbSerialParams.ByteSize = 8;
			dcbSerialParams.StopBits = ONESTOPBIT;
			dcbSerialParams.Parity = NOPARITY;
			dcbSerialParams.fDtrControl = DTR_CONTROL_ENABLE;

			if (!SetCommState(io_handler_, &dcbSerialParams))
				printf("Warning: could not set serial port params\n");
			else {
				connected_ = true;
				PurgeComm(io_handler_, PURGE_RXCLEAR | PURGE_TXCLEAR);
			}
		}
	}
}

void SimpleSerial::CustomSyntax(string syntax_type) {

	ifstream syntaxfile_exist("syntax_config.txt");

	if (!syntaxfile_exist) {
		ofstream syntaxfile;
		syntaxfile.open("syntax_config.txt");

		if (syntaxfile) {
			syntaxfile << "json { }\n";
			syntaxfile << "greater_less_than < >\n";
			syntaxfile.close();
		}
	}

	syntaxfile_exist.close();

	ifstream syntaxfile_in;
	syntaxfile_in.open("syntax_config.txt");

	string line;
	bool found = false;

	if (syntaxfile_in.is_open()) {

		while (syntaxfile_in) {
			syntaxfile_in >> syntax_name_ >> front_delimiter_ >> end_delimiter_;
			getline(syntaxfile_in, line);

			if (syntax_name_ == syntax_type) {
				found = true;
				break;
			}
		}

		syntaxfile_in.close();

		if (!found) {
			syntax_name_ = "";
			front_delimiter_ = ' ';
			end_delimiter_ = ' ';
			printf("Warning: Could not find delimiters, may cause problems!\n");
		}
	}
	else
		printf ("Warning: No file open");
}

string SimpleSerial::ReadSerialPort(int reply_wait_time, string syntax_type) {

	DWORD bytes_read;
	char inc_msg[1];
	string complete_inc_msg;
	bool began = false;

	CustomSyntax(syntax_type);

	unsigned long start_time = time(nullptr);

	ClearCommError(io_handler_, &errors_, &status_);

	while ((time(nullptr) - start_time) < reply_wait_time) {

		if (status_.cbInQue > 0) {

			if (ReadFile(io_handler_, inc_msg, 1, &bytes_read, NULL)) {

				if (inc_msg[0] == front_delimiter_ || began) {
					began = true;

					if (inc_msg[0] == end_delimiter_)
						return complete_inc_msg;

					if (inc_msg[0] != front_delimiter_)
						complete_inc_msg.append(inc_msg, 1);
				}
			}
			else
				return "Warning: Failed to receive data.\n";
		}
	}
	return complete_inc_msg;
}

bool SimpleSerial::WriteSerialPort(char *data_sent)
{
	DWORD bytes_sent;

	unsigned int data_sent_length = strlen(data_sent);

	if (!WriteFile(io_handler_, (void*)data_sent, data_sent_length, &bytes_sent, NULL)) {
		ClearCommError(io_handler_, &errors_, &status_);
		return false;
	}
	else
		return true;
}

bool SimpleSerial::CloseSerialPort()
{
	if (connected_) {
		connected_ = false;
		CloseHandle(io_handler_);
		return true;
	}
	else
		return false;
}

SimpleSerial::~SimpleSerial()
{
	if (connected_) {
		connected_ = false;
		CloseHandle(io_handler_);
	}
}

struct Array {
	const char* array;
	int len;
};

std::vector<SimpleSerial*> serials;

EXPORT
void delArray(struct Array * arr) {
    delete arr->array;
	delete arr;
}

EXPORT
int initSerial(char* portName) {

	SimpleSerial* serial = new SimpleSerial(portName, CBR_9600);
	serials.push_back(serial);

	return serial->connected_ ? 0 : 1;

}

EXPORT
struct Array* readSerialPort(int handleID, int toWait, int syntaxType) {
    SimpleSerial* serial = serials[handleID];

    char* syntaxTypes[] = {"json", "greater_less_than", "example"};
    struct Array* arr = new struct Array;
    string str = serial->ReadSerialPort(toWait, syntaxTypes[syntaxType]);

    char* str_new = new char[str.length() + 1];
    strcpy(str_new, str.c_str());
    arr->array = str_new;
    arr->len = str.length();
    return arr;
}

EXPORT
void closeSerialPort(int handleID) {

	serials[handleID]->CloseSerialPort();

}

EXPORT
void maximizeWindow() {
    char windowName[] = "mars_nav";
    wchar_t wtext[20];
    mbstowcs(wtext, windowName, strlen(windowName)+1);//Plus null
    LPWSTR ptr = wtext;
	HWND windowHandle = FindWindowW(nullptr, ptr);
	if (windowHandle != nullptr) {
		ShowWindow(windowHandle, SW_MAXIMIZE);
	}
}


struct SerialPorts {
	char*** portData;
	int numOfPorts;
};

EXPORT
struct SerialPorts* getSerialPorts() {
    HKEY hKey;
    LPCWSTR keyPath = L"HARDWARE\\DEVICEMAP\\SERIALCOMM";
    if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, keyPath, 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        char valueName[256];
        DWORD valueNameSize = sizeof(valueName);
        char portName[256];
        DWORD portNameSize = sizeof(portName);
        DWORD index = 0;
        int count = 0;

        char*** portData = (char***)malloc(MAX_PORTS * sizeof(char**));

        while (count < MAX_PORTS && RegEnumValueA(hKey, index, valueName, &valueNameSize, NULL, NULL, (LPBYTE)portName, &portNameSize) == ERROR_SUCCESS) {
            portData[count] = (char**)malloc(2 * sizeof(char*));
            portData[count][0] = (char*)malloc(portNameSize);
            portData[count][1] = (char*)malloc(valueNameSize);

            snprintf(portData[count][0], portNameSize + 1, "%s\0", portName);
            snprintf(portData[count][1], valueNameSize + 1, "%s\0", valueName);
            valueNameSize = sizeof(valueName);
            portNameSize = sizeof(portName);
            index++;
            count++;
        }

        RegCloseKey(hKey);

        struct SerialPorts* ports = new struct SerialPorts;
        ports->portData = portData;
        ports->numOfPorts = count;
        return ports;
    }

    return NULL; // Error
}

/*
int main() {

	ofstream MyFile("syntax_config.txt");
  	if (MyFile) {
  		MyFile << "json { }\ngreater_less_than < >\nexample [ ]";
  		MyFile.close();
	}

	int result = initSerial("\\\\.\\COM6");
	if (result == 0) {
		while(1) {
			struct Array* arr = readSerialPort(0, 2, 0);
			for (int i = 0 ; i < arr->len ; i++) {
				cout << arr->array[i] << " ";
			}
			cout << endl;
		}
	}

	return 0;

}*/
