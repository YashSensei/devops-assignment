import {defineConfig} from '@playwright/test';
export default defineConfig({testDir:'./tests',workers:1,timeout:60000,use:{baseURL:process.env.APP_URL||'http://127.0.0.1:3000',headless:true,video:'on',trace:'retain-on-failure',viewport:{width:1440,height:1050}}});
