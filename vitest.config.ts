import { defineConfig } from 'vitest/config';
export default defineConfig({ test:{ include:['src/**/*.test.ts'], fileParallelism:false, env:{DATABASE_PATH:'data/osufood-test.sqlite'} } });
