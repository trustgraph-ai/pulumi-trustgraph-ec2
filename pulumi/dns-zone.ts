
// Fetches an existing DNS zone

import * as aws from "@pulumi/aws";

import { awsProvider } from './aws-provider';

import { hostedDomain } from './config';

export const zone = aws.route53.getZoneOutput(
    {
	name: hostedDomain,
    },
    { provider: awsProvider }
);

