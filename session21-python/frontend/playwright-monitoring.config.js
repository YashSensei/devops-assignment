import {defineConfig} from '@playwright/test';
export default defineConfig({testDir:'./monitoring-tests',workers:1,timeout:240000,use:{headless:true,viewport:{width:1440,height:1050},video:'on'}});
