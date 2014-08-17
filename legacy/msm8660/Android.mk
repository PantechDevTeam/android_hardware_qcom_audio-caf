#AUDIO_POLICY_TEST := true
#ENABLE_AUDIO_DUMP := true

LOCAL_PATH := $(call my-dir)

common_cflags := -D_POSIX_SOURCE
ifeq ($(strip $(QCOM_FM_ENABLED)),true)
  common_cflags += -DQCOM_FM_ENABLED
endif

ifneq ($(strip $(QCOM_TUNNEL_LPA_ENABLED)),false)
  common_cflags += -DQCOM_TUNNEL_LPA_ENABLED
endif

ifeq ($(strip $(QCOM_VOIP_ENABLED)),true)
  common_cflags += -DQCOM_VOIP_ENABLED
endif

ifneq ($(strip $(QCOM_TUNNEL_LPA_ENABLED)),false)
  common_cflags += -DTUNNEL_PLAYBACK
endif

ifneq ($(strip $(QCOM_ACDB_ENABLED)),false)
  common_cflags += -DQCOM_ACDB_ENABLED
endif

ifeq ($(BOARD_HAVE_BLUETOOTH),true)
  common_cflags += -DWITH_A2DP
endif

ifeq ($(BOARD_HAVE_SAMSUNG_AUDIO),true)
  common_cflags += -DSAMSUNG_AUDIO
endif

ifeq ($(BOARD_HAVE_SONY_AUDIO),true)
  common_cflags += -DSONY_AUDIO
endif

ifeq ($(BOARD_HAVE_PRESTO_AUDIO),true)
  common_cflags += -DPRESTO_AUDIO
endif

ifeq ($(BOARD_HAVE_BACK_MIC_CAMCORDER),true)
  common_cflags += -DBACK_MIC_CAMCORDER
endif

include $(CLEAR_VARS)

LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES := \
    AudioHardware.cpp \
    audio_hw_hal.cpp

LOCAL_SHARED_LIBRARIES := \
    libcutils       \
    libutils        \
    libmedia        \
    libaudioalsa    \
    libacdbloader   \
    libacdbmapper

# hack for prebuilt
$(shell mkdir -p $(OUT)/obj/SHARED_LIBRARIES/libaudioalsa_intermediates/)
$(shell touch $(OUT)/obj/SHARED_LIBRARIES/libaudioalsa_intermediates/export_includes)
$(shell mkdir -p $(OUT)/obj/SHARED_LIBRARIES/libacdbloader_intermediates/)
$(shell touch $(OUT)/obj/SHARED_LIBRARIES/libacdbloader_intermediates/export_includes)
$(shell mkdir -p $(OUT)/obj/SHARED_LIBRARIES/libacdbmapper_intermediates/)
$(shell touch $(OUT)/obj/SHARED_LIBRARIES/libacdbmapper_intermediates/export_includes)

ifeq ($(TARGET_SIMULATOR),true)
 LOCAL_LDLIBS += -ldl
else
 LOCAL_SHARED_LIBRARIES += libdl
endif

LOCAL_STATIC_LIBRARIES := \
    libmedia_helper \
    libaudiohw_legacy \
    libaudiopolicy_legacy \

LOCAL_MODULE := audio.primary.msm8660
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional

LOCAL_C_INCLUDES := $(TARGET_OUT_HEADERS)/mm-audio/audio-alsa
LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audcal
LOCAL_C_INCLUDES += $(TARGET_OUT_HEADERS)/mm-audio/audio-acdb-util
LOCAL_C_INCLUDES += hardware/libhardware/include
LOCAL_C_INCLUDES += hardware/libhardware_legacy/include
LOCAL_C_INCLUDES += frameworks/base/include
LOCAL_C_INCLUDES += system/core/include
LOCAL_C_INCLUDES += system/media/audio_utils/include

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

LOCAL_CFLAGS += $(common_cflags) -Wno-error

include $(BUILD_SHARED_LIBRARY)

ifeq ($(USE_LEGACY_AUDIO_POLICY), 1)
# The audio policy is implemented on top of legacy policy code
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    AudioPolicyManager.cpp \
    audio_policy_hal.cpp

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libutils \
    libmedia

LOCAL_STATIC_LIBRARIES := \
    libaudiohw_legacy \
    libmedia_helper \
    libaudiopolicy_legacy

LOCAL_MODULE := audio_policy.msm8660
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional

LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

LOCAL_C_INCLUDES += hardware/libhardware_legacy/audio

LOCAL_CFLAGS += $(common_cflags) -Wno-error

include $(BUILD_SHARED_LIBRARY)
endif

# Load audio_policy.conf to system/etc/
include $(CLEAR_VARS)
LOCAL_MODULE       := audio_policy.conf
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)/
LOCAL_SRC_FILES    := audio_policy.conf
include $(BUILD_PREBUILT)
