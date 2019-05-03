/**
 * Created by dahl3702 on 3/21/2019.
 */

public with sharing class USTEventEmailLinkController {

    public String URLVar { get; set; }
    Private Blob key = Blob.valueOf('o@ac$jqPQ0EnIdna1KjWcA^f3MSKefnW');
    public String output { get; set; }


    public USTEventEmailLinkController() {
        URLVar = '';
        URLVar = ApexPages.currentPage().getParameters().get('link');
        output = ' ';
        //String encrptVar = createEncrypted(URLVar);
//        String encrptVar = getDecrypt(URLVar);
//        output += '<br/>Decrypt : ' + encrptVar + '<br/>';
        output += '<br/>Decrypted : ' + getDecrypt(URLVar)+ '<br/>';


    }

/*
    %%[
    var @encAES
    var @password
    var @salt
    var @initVector
            var @ContactID
            set @ContactID = "%%ContactID%%"
            set @password = "o@ac$jqPQ0EnIdna1KjWcA^f3MSKefnW"
            set @salt="0000000000000000"
            set @initVector = "00000000000000000000000000000000"
            set @encAES=EncryptSymmetric(@ContactID,"AES",@null,@password,@null,@salt,@null,@initVector)
            ]%%
*/


            //CookieValue, String CookieName
    public String createEncrypted(String thing2Encrypt) {
        Blob data = EncodingUtil.base64Decode(thing2Encrypt);
        Blob encrypted = Crypto.encryptWithManagedIV('AES256', key, data);
        String encodedCipherText = EncodingUtil.base64Encode(encrypted);
        encodedCipherText = EncodingUtil.urlEncode(encodedCipherText, 'UTF-8');
        return encodedCipherText;
    }

    public String getDecrypt(String thing2Decrypt) {
        String deCrypt = '';
        if (String.isNotBlank(thing2Decrypt)) {

                Blob decrypted = Crypto.decryptWithManagedIV(
                        'AES256',
                        key,
                        EncodingUtil.base64Decode(
                                EncodingUtil.urlDecode(thing2Decrypt, 'UTF-8')
                        )
                );
                deCrypt = decrypted.toString();

        }
        return deCrypt;
    }

}