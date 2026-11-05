# Third-Party Licenses

The Spreedly iOS SDK frameworks include code from the projects below. Each section lists the
version shipped, the frameworks that contain it, and the license and notice texts that come
with it. Not included, because your app adds them itself: Forter3DS.

<!-- Generated from the workspace Package.resolved; regenerate instead of editing by hand. -->

| Library | Version | Included in | License |
|---|---|---|---|
| [Braintree](#braintree) | 7.4.0 | SpreedlyBraintree | MIT |
| [Datadog](#datadog) | 3.18.0 | SpreedlyCore | Apache-2.0 |
| [Stripe](#stripe) | 25.17.0 | SpreedlyStripeAPM, SpreedlyStripeRadar | MIT |
| [Paze UI](#paze-ui) | 2026-08-04 | SpreedlyPaze | Proprietary - embed and redistribute granted to Spreedly |

## Braintree

<!-- third-party: braintree_ios 7.4.0 sha256:c9f7a994621cf9b40726c24934bf6a266158310a9a4df2288ec2191aaa3a1650 -->
- Version: 7.4.0
- Source: https://github.com/braintree/braintree_ios
- Included in: SpreedlyBraintree
- License: MIT

### LICENSE

```text
Copyright (c) 2014-2016 Braintree, a division of PayPal, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

### Code distributed with Braintree

- PPRiskMagnes: PayPal fraud-detection library distributed as a binary in braintree_ios.

## Datadog

<!-- third-party: dd-sdk-ios 3.18.0 sha256:5e19b681296c4447e61d024e75e74f1d80652ba9c309f3541a610b28e5e8b088 -->
- Version: 3.18.0
- Source: https://github.com/DataDog/dd-sdk-ios
- Included in: SpreedlyCore
- License: Apache-2.0

### NOTICE

```text
Datadog dd-sdk-ios
Copyright 2019 Datadog, Inc.

This product includes software developed at Datadog (https://www.datadoghq.com/).
```

### LICENSE

```text
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright 2017 Datadog, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

### Code distributed with Datadog

- Kronos: Apache-2.0 — Copyright (C) 2016 Lyft Inc. and MobileNativeFoundation — Vendored by Datadog; listed in Datadog's LICENSE-3rdparty.csv.
- AnyCodable: MIT — Copyright 2018 Read Evaluate Press, LLC — Vendored by Datadog; listed in Datadog's LICENSE-3rdparty.csv.

#### AnyCodable license

```text
This file includes software developed by Flight School, https://flight.school/ and altered by Datadog.
Use of this source code is governed by MIT license:

Copyright 2018 Read Evaluate Press, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
```

## Stripe

<!-- third-party: stripe-ios-spm 25.17.0 sha256:41ca00d8530d9dc14775f068b3ae1a5aaa5c1465ed2649abe6086d19c8b0b45a -->
- Version: 25.17.0
- Source: https://github.com/stripe/stripe-ios-spm
- Included in: SpreedlyStripeAPM, SpreedlyStripeRadar
- License: MIT

### LICENSE

```text
The MIT License

Copyright (c) 2011- Stripe, Inc. (https://stripe.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## Paze UI

<!-- third-party: ews-paze-ui 2026-08-04 sha256:8a36df77a3e1b55bc5207e2efe43df7a2d62ce6aa57af75a0818b5462856407e -->
- Supplier: Early Warning Services, LLC
- Received: 2026-08-04 (source drop)
- Added to this repository: 2026-08-25
- Included in: SpreedlyPaze
- License: Proprietary - embed and redistribute granted to Spreedly
- Copyright: Copyright Early Warning Services, LLC
- Provenance record: `SpreedlyPaze/SpreedlyPaze/Vendor/UPSTREAM.md`

### Terms granted

Early Warning Services confirmed in writing that Spreedly may embed the Paze production component source in this SDK and ship it to merchant customers. The grant covers this source drop; a new drop is requested each time rather than tracking a versioned package.

### Files as received

| File | SHA-256 |
|---|---|
| `PazeButton.swift` | `4b0b418d802403b47965357a778358bc9586026be1d59ff8ec046aa85c567333` |
| `PazeButtonStyle.swift` | `f809ba35731db5b829c760a44dc5278cf2fb0ce9ea64f02c080ddefa1d2a6a7f` |
| `PazeAssets.xcassets/Colors/Contents.json` | `0fd49ba3c3585c709678e0046a821c3c60685ec7063720d30d3a3448be3a208b` |
| `PazeAssets.xcassets/Colors/PazeLogo.colorset/Contents.json` | `c21fd20a2f7d88e805275dfef4d92f1c5ec62039328b9693fc9263b39b4bce3f` |
| `PazeAssets.xcassets/Colors/PazeMessageFilled.colorset/Contents.json` | `1df7a42788b3af91c69fd7d36515c8d7d42b05b75da3a58dffe42cd66a21d549` |
| `PazeAssets.xcassets/Colors/PazeMessageOutline.colorset/Contents.json` | `daa13a64622689f4f1172bde9683292720e96489157481be998867d1c3ad4c74` |
| `PazeAssets.xcassets/Colors/PazeMessageOutlineContainer.colorset/Contents.json` | `d0828c53dec72d97618fb2eeff398a70be9e1927e0a23d9e3842b84603a8f8eb` |
| `PazeAssets.xcassets/Colors/PazeMessageText.colorset/Contents.json` | `ed497210fdd8e5afd173eb9f0c35ad6d37062115c8a10eb858e9570c161dea97` |
| `PazeAssets.xcassets/Colors/PazeMidnight.colorset/Contents.json` | `480974b0a65b20da710ba24e0aebfd246785ebfa396649e302f388edeec5a270` |
| `PazeAssets.xcassets/Colors/PazePrimary.colorset/Contents.json` | `89d1bab156386afc52b4f5e5b044f50ccacd3a15bfe88fceba3136b01d415280` |
| `PazeAssets.xcassets/Contents.json` | `0fd49ba3c3585c709678e0046a821c3c60685ec7063720d30d3a3448be3a208b` |
| `PazeAssets.xcassets/Images/Contents.json` | `0fd49ba3c3585c709678e0046a821c3c60685ec7063720d30d3a3448be3a208b` |
| `PazeAssets.xcassets/Images/PazeLabelCheckout.imageset/Contents.json` | `724e434b05beece97da7170d529b036d0a7d823a67f7fdb095de9f6994459ee4` |
| `PazeAssets.xcassets/Images/PazeLabelCheckout.imageset/PazeLabelCheckout.pdf` | `7cf86d336a54590c1acf5dcb9d4497ff3fcd3ab7661ebca1eb46644b9a425441` |
| `PazeAssets.xcassets/Images/PazeLabelCheckoutWith.imageset/Contents.json` | `fdac7040052eeb18c940d27ea7a8d65042dc2194f22d6c3b5f07267e72dafa9f` |
| `PazeAssets.xcassets/Images/PazeLabelCheckoutWith.imageset/PazeLabelCheckoutWith.pdf` | `673180eac8d10293f9fe19c5853d850a189c29d1e3fb456efe6296d48b358b08` |
| `PazeAssets.xcassets/Images/PazeLabelDonateWith.imageset/Contents.json` | `d033b33307cc0d87989bceee9b745a9822f3c9c787efe7d38cc2e484ac77a0f3` |
| `PazeAssets.xcassets/Images/PazeLabelDonateWith.imageset/PazeLabelDonateWith.pdf` | `80131038d40d3e2365a60a90f350ab942bbd54a54c35ec1853e1e09970b41078` |
| `PazeAssets.xcassets/Images/PazeLabelPazeCheckout.imageset/Contents.json` | `7e856ad450976f2feb11bb5a06d8c5041f68769189992222c3a30447fca9f78f` |
| `PazeAssets.xcassets/Images/PazeLabelPazeCheckout.imageset/PazeLabelPazeCheckout.pdf` | `cd0a550c217d2801d10616edbd7bba2601af0c8411f81e15da8855de638542de` |
| `PazeAssets.xcassets/Images/PazeLogo.imageset/Contents.json` | `1cf052ca72221fdcb27f75f21bb1020fa31b149e3670ec1ef649235237afca2a` |
| `PazeAssets.xcassets/Images/PazeLogo.imageset/PazeLogo.pdf` | `48f0f0f41d74213885027b1013f4262d88a5edc94a7926f7a05ec185ce0d82f1` |
