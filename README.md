# Acoustic Content Sample App

## How to start

1. Please make sure Content Hub contains provided test data. Test data can be found in `Source Test Data/source_v3.zip`.

    > WCHtools (with instructions) required for pushing data model to the Content Hub can be found here: [wchtool docs](https://github.com/acoustic-content-samples/wchtools-cli)

1. Make sure you have access to repo `<path-to-repo>`

1. `git clone <link to repo>`

1. Checkout **development** branch to get the latest features

1. Open `AcousticContentSampleApp.xcodeproj`

1. Open `AcousticContentSampleApp/Data Layer/URLProvider.swift` file and update

    - `contentHubId` (also known as `tenantId`)  
    - `domainName` 
    
    with your Content Hub information.

1. Build and run the app.
