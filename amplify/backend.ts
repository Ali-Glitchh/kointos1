import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { storage } from './storage/resource';

/**
 * @see https://docs.amplify.aws/gen2/build-a-backend/ to add other resources
 */
export const backend = defineBackend({
  auth,
  data,
  storage,
});