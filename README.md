## Features

🎉**Card Payment**🎉

🎉**Bank Transfer Payment**🎉

🎉**Mobile Money Payment**🎉

## Getting started

Before you run, do the following in your `android/app/build.gradle`

Update your compileSDKVersion to latest

```
android {
    compileSdkVersion 32
    }
```

Update your minSDKVersion to 19

```
  defaultConfig {
        minSdkVersion 19
    }
```

## Usage

Simply call the `PayWithKora` class to start making payments with korapay. As simple as that. Please note that for reference its important you use a unique id. I recommend uuid. I have added it as part of the package. Please see example below to see how it is used.

Example

```
 final uniqueTransRef = PayWithPayStack().generateUuidV4()
 
 PayWithKora().now(
    context: context
    secretKey: "sk_live_XXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    customerEmail: "your@email.com",
    customerName: "Promise Amadi",
    reference: uniqueTransRef, 
    callbackUrl: "setup in your korapay dashboard eg https://korapay.callbackUrl.com"
    currency: "NGN",
    paymentChannel: ["bank_transfer", "card", "pay_with_bank", "mobile_money"],
    amount: 2000,
    customerNarration: "Payment for product Y",
    transactionCompleted: () {
        print("Transaction Successful");
    },
    transactionNotCompleted: () {
        print("Transaction Not Successful!");
    });
```

## Definitions

`context`
To aid in routing to screens

`secretKey`
Provided by korapay

`customerEmail`
Email address of the user/customer trying to make payment for receipt purpose

`customerName`
Name of the user/customer trying to make payment for record purpose

`reference`
Unique ID to recognise this transaction in your korapay dashboard. I've added uuidv4 to help with that. Kindly see the example in the readme. Alternatively you can create your own unique id.

`currency`
Currency user/customer should be charged in

`amount`
Amount or value user/customer should be charged.

`callbackUrl`
URL to redirect to after payment is successful, this helps close the session. This is setup in the Dashboard of korapay and the same URL setup is then provided here by you again. **This is very important for successful or failed transactions**

`paymentChannels [Optional]`
Payment Channels are provided to you by KoraPay and some may not be available based on your country and preferences set in your korapay dashboard. Example; `["card", "pay_with_bank", "bank_transfer", "mobile_money"]`

`transactionCompleted`
Execute a function when transaction is completed or is successful

`transactionNotCompleted`
Execute a function when transaction is not completed or is not successful

`customerNarration [Optional]`
Reason for payment

`metadata [Optional]`
Extra data for development purposes. Example:

```
 "metadata":{
        "key0": "test0",
        "key1": "test1",
        "key2": "test2",
        "key3": "test3",
        "key4": "test4"
    }
```

## Screenshots

<img alt="" src="https://user-images.githubusercontent.com/26738997/192014501-035de07d-1130-49b6-895c-32c3182676cf.png" width= 300/> <img alt="" src="https://user-images.githubusercontent.com/26738997/192014543-82674864-2851-4b2b-9f92-be73aa370702.png" width= 300/>
<img alt="" src="https://user-images.githubusercontent.com/26738997/192014596-0396ee68-febf-4bf9-8d74-30253c9c94fe.png" width= 300/> <img alt="" src="https://user-images.githubusercontent.com/26738997/192014634-a74376f8-7e96-4842-a133-58196f146b61.png" width= 300/>

## Additional information

For more information and bug reports, Contact me on github `@wizpna`

## 📝 Contributing, 😞 Issues and 🐛 Bug Reports

The project is open to public contribution. Please feel very free to contribute. Experienced an issue or want to report a bug? Please, report it <a href="https://github.com/wizpna/korapay/issues">here</a>. Remember to be as descriptive as possible.

## Support my Work 🙏🏽
Buy me coffee <a href="https://www.buymeacoffee.com/Bzfan73">here</a>. Thank you!