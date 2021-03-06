////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package flexUnitTests.binding.support.bindings.bindables
{

[Bindable]
public class OneLayerBindable
{
    public var bindableString:String;

    public var bindableNumber:Number;

    public var bindableBoolean:Boolean;

    public function getSomething():String{
        return bindableBoolean ? 'Internally true' : 'Internally false';
    }

    public function getSomethingBasedOn(something:Boolean):String{
        return bindableBoolean && something ? "Both are true" : (bindableBoolean ? "Local only" : "Inbound only");
    }

}
}