<#
Copyright 2018 cq01

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
#>
#修改E:\Program\Aria2\aria2c.exe 为自己的aria2c.exe地址，E:\Program\Aria2\aria2.conf为自己的aria2.conf地址（不要空格），再添加到计划任务，可以让aria开机自�?
if (!(Test-Path E:\Program\aria2\aria2.session)) {
	New-Item E:\Program\aria2\aria2.session
}
Start-Process -FilePath "E:\Program\Aria2\aria2c.exe" -ArgumentList "--conf-path=E:\Program\Aria2\aria2.conf" -Verb open -WindowStyle Hidden