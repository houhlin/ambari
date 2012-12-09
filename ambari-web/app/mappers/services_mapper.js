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

App.servicesMapper = App.QuickDataMapper.create({
  model : App.Service,
  config : {
    id : 'ServiceInfo.service_name',
    service_name : 'ServiceInfo.service_name',
    label : 'ServiceInfo.service_name',
    $health_status: 'LIVE',
    $work_status: 'true',
    $serviceAudit: [1, 2, 3],
    components_key : 'components',
    components : {
        id : 'ServiceComponentInfo.component_name',
        component_name : 'ServiceComponentInfo.component_name',
        //service_id : 'ServiceComponentInfo.service_name',
        service_name : 'ServiceComponentInfo.service_name',
        state: 'host_components[0].HostRoles.state',
        host_name: 'host_components[0].HostRoles.host_name'
      }
  }
});