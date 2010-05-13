# Copyright (C) 2007 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Definitions for building the Java library and associated tests.
#

#
# Common definitions for host and target.
#

# libcore is divided into modules.
#
# The structure of each module is:
#
#   src/
#       main/               # To be shipped on every device.
#            java/          # Java source for library code.
#            native/        # C++ source for library code.
#            resources/     # Support files.
#       test/               # Built only on demand, for testing.
#            java/          # Java source for tests.
#            native/        # C++ source for tests (rare).
#            resources/     # Support files.
#
# All subdirectories are optional (hence the "2> /dev/null"s below).

define all-main-java-files-under
$(foreach dir,$(1),$(patsubst ./%,%,$(shell cd $(LOCAL_PATH) && find $(dir)/src/main/java -name "*.java" 2> /dev/null)))
endef

define all-test-java-files-under
$(patsubst ./%,%,$(shell cd $(LOCAL_PATH) && find $(1)/src/test/java -name "*.java" 2> /dev/null))
endef

define all-core-resource-dirs
$(shell cd $(LOCAL_PATH) && ls -d */src/$(1)/{java,resources} 2> /dev/null)
endef

# The Java files and their associated resources.
core_src_files := $(call all-main-java-files-under,annotation archive auth awt-kernel concurrent crypto dalvik dom icu json logging luni luni-kernel math nio nio_char openssl prefs regex security security-kernel sql suncompat support text x-net xml)
core_resource_dirs := $(call all-core-resource-dirs,main)
test_resource_dirs := $(call all-core-resource-dirs,test)


#
# Build for the target (device).
#

# Definitions to make the core library.

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(core_src_files)
LOCAL_JAVA_RESOURCE_DIRS := $(core_resource_dirs)

ifeq ($(EMMA_INSTRUMENT),true)
LOCAL_SRC_FILES += $(call all-java-files-under, ../../external/emma/core ../../external/emma/pregenerated)
LOCAL_JAVA_RESOURCE_DIRS += ../../external/emma/core/res ../../external/emma/pregenerated/res
endif

LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_DX_FLAGS := --core-library

LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true

LOCAL_MODULE := core

include $(BUILD_JAVA_LIBRARY)

core-intermediates := ${intermediates}


# Make core-junit
include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-main-java-files-under,junit)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core
LOCAL_MODULE := core-junit
include $(BUILD_JAVA_LIBRARY)


# Definitions to make the core-tests libraries.
#
# We make a library per module, because otherwise the .jar files get too
# large, to the point that dx(1) can't cope (and the build is
# ridiculously slow).
#
# TODO: DalvikRunner will make this nonsense obsolete.

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,annotation)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-annotation
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,archive)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-archive
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,concurrent)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-concurrent
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,crypto)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-crypto
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,dom)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-dom
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,icu)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-icu
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,json)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-json
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,logging)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-logging
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,luni)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
# This module contains the top-level "tests.AllTests" that ties everything
# together, so it has compile-time dependencies on all the other test
# libraries.
# TODO: we should have a bogus module that just contains tests.AllTests for speed.
LOCAL_JAVA_LIBRARIES := \
        core \
        core-junit \
        core-tests-annotation \
        core-tests-archive \
        core-tests-concurrent \
        core-tests-crypto \
        core-tests-dom \
        core-tests-icu \
        core-tests-json \
        core-tests-logging \
        core-tests-luni-kernel \
        core-tests-math \
        core-tests-nio \
        core-tests-nio_char \
        core-tests-prefs \
        core-tests-regex \
        core-tests-security \
        core-tests-sql \
        core-tests-suncompat \
        core-tests-support \
        core-tests-text \
        core-tests-x-net \
        core-tests-xml
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-luni
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,luni-kernel)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-luni-kernel
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,math)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-math
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,nio)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-nio
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,nio_char)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-nio_char
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,prefs)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-prefs
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,regex)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-regex
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,security)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-security
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,sql)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-sql
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,suncompat)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-suncompat
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,support) $(call all-test-java-files-under,junit)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-support
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,text)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-text
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,x-net)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-x-net
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(call all-test-java-files-under,xml)
LOCAL_JAVA_RESOURCE_DIRS := $(test_resource_dirs)
LOCAL_NO_STANDARD_LIBRARIES := true
LOCAL_JAVA_LIBRARIES := core core-junit core-tests-dom core-tests-support
LOCAL_DX_FLAGS := --core-library
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := core-tests-xml
LOCAL_NO_EMMA_INSTRUMENT := true
LOCAL_NO_EMMA_COMPILE := true
include $(BUILD_JAVA_LIBRARY)

# This one's tricky. One of our tests needs to have a
# resource with a "#" in its name, but Perforce doesn't
# allow us to submit such a file. So we create it here
# on-the-fly.
TMP_RESOURCE_DIR := $(OUT_DIR)/tmp/
TMP_RESOURCE_FILE := org/apache/harmony/luni/tests/java/lang/test\#.properties

$(TMP_RESOURCE_DIR)$(TMP_RESOURCE_FILE):
	@mkdir -p $(dir $@)
	@echo "Hello, world!" > $@

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_EXTRA_JAR_ARGS := $(extra_jar_args) -C $(TMP_RESOURCE_DIR) $(TMP_RESOURCE_FILE)
$(LOCAL_INTERMEDIATE_TARGETS): $(TMP_RESOURCE_DIR)$(TMP_RESOURCE_FILE)

# Definitions for building a version of the core-tests.jar
# that is suitable for execution on the RI. This JAR would
# be better located in $HOST_OUT_JAVA_LIBRARIES, but it is
# not possible to refer to that from a shell script (the
# variable is not exported from envsetup.sh). There is also
# some trickery involved: we need to include some classes
# that reside in core.jar, but since we cannot incldue the
# whole core.jar in the RI classpath, we copy those classses
# over to our new file.
HOST_CORE_JAR := $(HOST_COMMON_OUT_ROOT)/core-tests.jar

$(HOST_CORE_JAR): PRIVATE_LOCAL_BUILT_MODULE := $(LOCAL_BUILT_MODULE)
$(HOST_CORE_JAR): PRIVATE_CORE_INTERMEDIATES := $(core-intermediates)
$(HOST_CORE_JAR): $(LOCAL_BUILT_MODULE)
	@rm -rf $(dir $<)/hostctsclasses
	$(call unzip-jar-files,$(dir $<)classes.jar,$(dir $<)hostctsclasses)
	@unzip -qx -o $(PRIVATE_CORE_INTERMEDIATES)/classes.jar dalvik/annotation/* -d $(dir $<)hostctsclasses
	@cp $< $@
	@jar uf $@ -C $(dir $<)hostctsclasses .

$(LOCAL_INSTALLED_MODULE): $(HOST_CORE_JAR)

$(LOCAL_INSTALLED_MODULE): run-core-tests

# Definitions to copy the core-tests runner script.

include $(CLEAR_VARS)
LOCAL_SRC_FILES := run-core-tests
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := run-core-tests
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := run-core-tests-on-ri
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS := tests
LOCAL_MODULE := run-core-tests-on-ri
include $(BUILD_PREBUILT)


#
# Build for the host.
#

ifeq ($(WITH_HOST_DALVIK),true)

    # Definitions to make the core library.

    include $(CLEAR_VARS)

    LOCAL_SRC_FILES := $(core_src_files)
    LOCAL_JAVA_RESOURCE_DIRS := $(core_resource_dirs)

    LOCAL_NO_STANDARD_LIBRARIES := true
    LOCAL_DX_FLAGS := --core-library

    LOCAL_NO_EMMA_INSTRUMENT := true
    LOCAL_NO_EMMA_COMPILE := true

    LOCAL_MODULE := core

    include $(BUILD_HOST_JAVA_LIBRARY)

endif
