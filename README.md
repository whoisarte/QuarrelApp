
# Quarrel

This application only serves a general purpose, the registration of buyers for a raffle that I decided to do because of some things I had that I didn't use.

The application is simple, it shows two screens, one with a grid listing containing 100 numbers. Each number is assignable to a person who pays $x. Based on that amount, the number can have 3 statuses:
Paid
Partially paid
Unpaid

Each status changes the color of the number to make it visible and to understand the status of each number, assigned of course to each person.

The application is developed in UIKit, using the MVVM architecture.
It performs fetching, construction and modification of number data using Firebase (Firestore to be more precise) and a local saving of values using UserDefaults.


Technologies Used:

-  UIKit
    - Storyboard / XIB
    - UINavigationController
    - UICollectionView / UICollectionViewCell
    - UIStackView - UIView - UIButton
- Persistence
    - Firestore
    - UserDefaults
- Git
- Architecture
    - MVVM


I performed it just for the registry purpose, so it is relatively simple. 
