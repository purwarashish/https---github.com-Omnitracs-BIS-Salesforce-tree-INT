public with sharing class CryptoUtils {

//Method to return value instead of commiting to record
    public static string encrypt(string plainText)
    {
    // Generate the data to be encrypted.                   
        Blob data = Blob.valueOf(plainText);
                
    // Encrypt the data and have Salesforce.com generate the initialization vector          
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', getKey(), data);
      
    //URL Encode to transform from blob to string
        return EncodingUtil.base64Encode(encryptedData);   
    }

    public static string decrypt(string encryptedString){
        
    //Decrypte value...  Note value is URLencoded...  Must Decode prior to decrypting   
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', getKey(), EncodingUtil.base64Decode(encryptedString));
        return decryptedData.toString();
    }
    
    //Common method to get key from Custom Label
    private static Blob getKey() {
        return Blob.valueOf(Label.AES256EncryptionKey);
    }
}