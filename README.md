# IME Pay QR Scanner for iOS Apps

Scan QR Code issued by IME Pay to its merchants.

* Features
* Requirements
* Installation
* Usage
* License

## Features

- [x] Scan IME Pay merchant's QR Code
- [x] SDK Returns merchant's code and merchant name.

### Requirements

* iOS 8+

### Installation

To integrate Alamofire into your Xcode project using CocoaPods, specify it in your Podfile:

Say what the step will be

```
platform :ios, '11.4'
use_frameworks!

target '<Your Target Name>' do
    pod 'IMEPayQRScanner'
end
```

Then, run the following command:

```
$ pod install
```

## Usage

```
let viewController = Your view controller from which scanner is opened

let coordinator = IMPScannerCoordinator(parentViewController: viewController)

```
```
coordinator.onScanSuccess  = { name, mobileNumOrCode in
       print("Merchant Name \(name ?? "")")
       print("Merchant Mobile Number / Code \(mobileNumOrCode ?? "")") // Use this for transactions
}
        
coordinator.onScanFailure = {
       print("Scanner failure message \($0 ?? "")")
}
coordinator.start()
```

### License

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

