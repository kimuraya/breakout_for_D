module convert;

import std.windows.charset;
import std.conv;

//文字列をUTF-8からマルチバイト文字列に変換する
string convertsMultibyteStringOfUtf(string str) {
	return to!string(toMBSz(str));
}