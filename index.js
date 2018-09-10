/** @format */

import {AppRegistry} from 'react-native';
import App from './App';
import App2 from './App2';
import {name as appName} from './app.json';

// AppRegistry.registerComponent(appName, () => App);
AppRegistry.registerComponent("App", () => App);
AppRegistry.registerComponent("App2", () => App2);
