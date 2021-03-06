#
# $1 - some string possibly quoted with double quotes
#
# returns:
#   double-quote and whitespace stripped version of $(1)
#
define qstrip
$(strip $(subst ",,$(1)))
endef

#
# $1 - some string possibly containing newline chars
#
# returns:
#   the same string with all newline chars replaced with spaces
#
define newline2space
$(subst $(_newline),$(_space),$(1))
endef

#
# $1 - pattern (regular wildcard parameter)
#
# Overcomes the following deficiency of $(sort $(wildcard ...))
#
# $(sort xyz-suffix xyz):
#    returns (as expected) "xyz xyz-suffix"
# $(sort xyz-suffix/... xyz/...):
#    however returns "xyz-suffix/... xyz/..."
#    which is actually correct (ASCII code of "-" is smaller than that of "/")
#    but not what one would expect when sorting is applied to filepaths.
#
# sorted-wildcard returns "xyz/... xyz-suffix/..." for "xyz-suffix/... xyz/..."
#
define sorted-wildcard
$(strip $(subst $(_bang),/,$(sort $(subst /,$(_bang),$(wildcard $(1))))))
endef

#
# $1 - some string representing a version of some package
# $2 (optional) - number of version components to be included, default 2
#
# returns:
#   major version of the package, i.e. x.y for x.y.z
#
define GET_MAJOR_VERSION
$(strip $(subst $(_space),.,$(wordlist 1,$(if $(2),$(2),2),$(subst .,$(_space),$(1)))))
endef


# SUBST_MAP
# Substitute according to map src:dst
#  $1 - some string
#  $2 - list of src:dst pairs
SUBST_MAP = $(strip		\
	$(eval __tmp := $1)	\
	$(foreach s,$2,		\
		$(eval __tmp := $(subst $(word 1,$(subst :, ,$s)),$(word 2,$(subst :, ,$s)),$(__tmp))))	\
	$(__tmp))
SUBST_MAP_TOLOWER := A:a B:b C:c D:d E:e F:f G:g H:h I:i J:j K:k L:l M:m N:n O:o P:p Q:q R:r S:s T:t U:u V:v W:w X:x Y:y Z:z
SUBST_MAP_TOUPPER := a:A b:B c:C d:D e:E f:F g:G h:H i:I j:J k:K l:L m:M n:N o:O p:P q:Q r:R s:S t:T u:U v:V w:W x:X y:Y z:Z
SUBST_MAP_LEGAL_VARNAME := -:_ .:_
SUBST_MAP_TOUPPER_NAME := $(SUBST_MAP_TOUPPER) $(SUBST_MAP_LEGAL_VARNAME)
SUBST_MAP_TOLOWER_NAME := $(SUBST_MAP_TOLOWER) $(SUBST_MAP_LEGAL_VARNAME)

# TOUPPER_NAME
# Converts lower-case letters to upper-case, all characters which cannot be used in identifiers to underscore
#   $1 = string to convert
TOUPPER_NAME = $(call SUBST_MAP,$1,$(SUBST_MAP_TOUPPER_NAME))

# LEGAL_VARNAME
# Converts all characters which cannot be used in identifiers to underscore
#   $1 = string to convert
LEGAL_VARNAME = $(call SUBST_MAP,$1,$(SUBST_MAP_LEGAL_VARNAME))

#
# $1 - git repository
# $2 - (optional) branch name, if omitted "master" is used
#
# returns:
#   latest revision of the specified branch
#
define git-get-latest-revision
$(shell rev=$$(git ls-remote --heads $(strip $(1)) $(if $(strip $(2)),$(strip $(2)),master) | sed -rn -e 's,^([0-9a-f]{10})[0-9a-f]{30}.*,\1,p'); echo "$${rev:-FAILED_TO_DETERMINE_LATEST_REVISION}")
endef

#
# $1 - menuconfig file
# $2 - (optional) dir name, if omitted "make" is used
#
define genin-get-considered-packages
$(shell cat $1 2>/dev/null | sed -r -n -e 's,^[ \t]*source[ \t]+$(if $(strip $(2)),$(strip $(2)),make)/([^/]+)/(Config|external)[.]in(.libs)?.*,\1,p' | sort -u)
endef

#
# $1 - dir
# $2 - name of the file to look for
# $3 - (optional) subdirs to exclude
#
define get-subdirs-containing
$(shell find -L $(strip $(1)) -maxdepth 2 -name "$(strip $(2))" -printf "%h\n" $(if $(strip $(3)),| grep -v -E "$(strip $(1))/$(subst $(_space),|,$(strip $(3)))") | sed -r -e 's,^$(strip $(1))/,,' | sort -u)
endef
