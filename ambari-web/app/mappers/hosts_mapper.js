/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


App.hostsMapper = App.QuickDataMapper.create({
  model : App.Host,
  config : {
    id : 'Hosts.host_name',
    host_name : 'Hosts.host_name',
    cluster_id: 'Hosts.cluster_name',//1
    $components: [1,2,3],
    cpu : 'Hosts.cpu_count',
    memory : 'Hosts.total_mem',
    disk_info: 'Hosts.disk_info',
    $disk_usage: '40',
    $health_status: 'LIVE',
    $load_avg: '0.2, 1.2, 2.4',
    $cpu_usage: 33,
    $memory_usage: 26,
    $network_usage: 36,
    $io_usage: 39,
    last_heart_beat_time : "Hosts.last_heartbeat_time",
    os : 'Hosts.os_arch',
    os_type : 'Hosts.os_type',
    ip : 'Hosts.ip'
  }

});