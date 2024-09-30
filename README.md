<p align="center">
  <img src="https://github.com/user-attachments/assets/b5cad764-5562-466b-b8ee-6b5cb6ca5985" />
</p>

# Butter

Butter is an app that lets you catalog and track your movies. It works offline and also integrates with the [ButterBackend](https://github.com/CTNeptune/ButterBackend) to back up and store your catalogs.

## Features

- **Offline Support**: Store your catalogs locally and access them even without an internet connection.
- **Online Sync**: Use a [ButterBackend](https://github.com/CTNeptune/ButterBackend) instance to synchronize your movie catalog across devices.
- **Robust Search**: Use tags and formats to find the right movie.

## Screenshots
<img src="https://github.com/user-attachments/assets/afc157c8-6a8b-4c7c-9507-1b977abba587" width="20%" height="20%" />
<img src="https://github.com/user-attachments/assets/5d31d1f4-eb47-4b58-87a9-60869be55bd1" width="20%" height="20%" />
<img src="https://github.com/user-attachments/assets/fd3c2b57-29d5-416f-81bb-cc24b3611791" width="20%" height="20%" />
<img src="https://github.com/user-attachments/assets/8eba6737-1c41-4d27-a650-22c4528018cb" width="20%" height="20%" />

## Building

This project is built with Flutter. Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed and configured on your machine.

1. **Install Flutter SDK**: Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) based on your operating system.
   
   - Verify Flutter installation:
     ```bash
     flutter doctor
     ```
   - Then make sure the dependencies are updated:
     ```bash
     flutter pub get
     ```
2. **Set Up Emulator or Device**: Ensure you have a connected Android/iOS device or set up an emulator.
3. **Use the app**: If you want to use the app locally and offline, you can press "Use app offline" and skip the rest of the steps
4. **Start backend (Optional for Cloud Sync)**: If you want to sync your movie catalog online, set up [ButterBackend](https://github.com/CTNeptune/ButterBackend) on your local machine or a server. In the sign-in screen, set "Host" to the IP of the ButterBackend server.
5. **Create account**: Create a username and password for your account, then sign in.
6. **Done!** You're ready to go!

## Contributions

Contributions are welcome! Feel free to fork the repository and submit pull requests.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
