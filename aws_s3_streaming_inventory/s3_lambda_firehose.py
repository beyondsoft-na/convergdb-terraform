# ConvergDB - DevOps for Data
# Copyright (C) 2018 Beyondsoft Consulting, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import boto3
import json
import time
import os

def lambda_handler(event, context):
    # get the value of FIREHOSE_STREAM_NAME
    try:
        firehose_stream_name = os.environ['FIREHOSE_STREAM_NAME']
    except KeyError:
        print("Please specify the value of env var FIREHOSE_STREAM_NAME"
               "in lambda function")
        raise

    # get kinesis firehose client
    firehose = boto3.client('firehose')
    # iterate the Records in event
    for e in event['Records']:
        # save one record in a dictionary
        dic = {}
        dic['last_modified_timestamp'] = e["eventTime"].replace("T"," ").replace("Z", "")
        dic['bucket'] = e["s3"]['bucket']['name']
        dic['key'] = e["s3"]['object']['key']
        dic['size'] = e["s3"]['object']['size']
        dic['e_tag'] = e["s3"]['object']['eTag']
        dic['sequencer'] = e["s3"]['object']['sequencer']

        # put the record into firehose delivery stream
        record = (json.dumps(dic) + "\n").encode()
        firehose.put_record( DeliveryStreamName = firehose_stream_name,
                             Record = {
                                'Data' : record
                             }
                           )
        print(record)
    return
