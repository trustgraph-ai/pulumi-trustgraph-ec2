
// Creates an ECS cluster using EC2 compute

import * as fs from 'fs';
import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

import { awsProvider } from './aws-provider';
import { prefix, tags, region } from './config';

////////////////////////////////////////////////////////////////////////////

const deployAsset = new pulumi.asset.FileAsset("../output.zip");

////////////////////////////////////////////////////////////////////////////

export const bucket = new aws.s3.BucketV2(
    "bucket",
    {
        bucketPrefix: "init-resources",
    },
    { provider: awsProvider }
);

export const deployObject = new aws.s3.BucketObjectv2(
    "deploy-resource",
    {
	key: "output.zip",
        bucket: bucket.id,
        source: deployAsset,
    },
    { provider: awsProvider }
);

