local https = require("ssl.https")
local json = require ("dkjson")

local luaVkApi = {}

local authUrl = "https://oauth.vk.com/authorize" .. "?client_id={APP_ID}"
  .. "&scope={PERMISSIONS}" .. "&redirect_uri={REDIRECT_URI}"
  .. "&display={DISPLAY}" .. "&v={API_VERSION}" .. "&response_type=token"
local apiRequest = "https://api.vk.com/method/{METHOD_NAME}" .. "?{PARAMETERS}"
  .. "&access_token={ACCESS_TOKEN}" .. "&v={API_VERSION}"
local requiredParameterMsg = "ERROR! This parameter is required:"

-----------------------
--Common util methods--
-----------------------
function luaVkApi.invokeApi(method, params)
  -- load properties
  file = io.open("luaVkApi.properties")
  local properties = {}
  for line in file:lines() do
    for key, value in string.gmatch(line, "(.-)=(.-)$") do
      properties[key] = value
    end
  end
  -- parse method parameters
  local parameters = ""
  if params ~= nil then
    for key, value in pairs(params) do
      parameters = parameters .. key .. "=" .. value .. "&"
    end
  end

  local reqUrl = string.gsub(apiRequest, "{METHOD_NAME}", method)
  reqUrl = string.gsub(reqUrl, "{ACCESS_TOKEN}", properties.accessToken)
  reqUrl = string.gsub(reqUrl, "{API_VERSION}", properties.apiVersion)
  reqUrl = string.gsub(reqUrl, "{PARAMETERS}&", parameters)
  return https.request(reqUrl)
end

function luaVkApi.stringToJSON(jsonString_)
  local jsonString = jsonString_
  return json.decode(jsonString, 1, nil)
end

function luaVkApi.jsonToString(jsonObject_)
  local jsonObject = jsonObject_
  return json.encode(jsonObject)
end

-----------------------
--      Users        --
-----------------------
function luaVkApi.getUsersInfo(userIds, returnedFields, nameCase)
  return luaVkApi.invokeApi("users.get", {user_ids=userIds, fields=returnedFields,
      name_case=nameCase})
end

function luaVkApi.searchUsers(queryString, sortVal, offsetVal, countVal, returnedFields,
    cityVal, countryVal, hometownVal, universityCountry, universityVal, universityYear,
    universityFaculty, universityChair, sexVal, statusVal, ageFrom, ageTo, birthDay,
    birthMonth, birthYear, isOnline, hasPhoto, schoolCountry, schoolCity, schoolClass,
    schoolVal, schoolYear, religionVal, interestsVal, companyVal, positionVal, groupId,
    fromList)
  return luaVkApi.invokeApi("users.search", {q=queryString, sort=sortVal, offset=offsetVal,
      count=countVal, fields=returnedFields, city=cityVal, country=countryVal, 
      hometown-hometownVal, university_country=universityCountry, university=universityVal,
      university_year=universityYear, university_faculty=universityFaculty, 
      university_chair=universityChair, sex=sexVal, status=statusVal, age_from=ageFrom,
      age_to=ageTo, birth_day=birthDay, birth_month=birthMonth, birth_year=birthYear,
      online-isOnline, has_photo=hasPhoto, school_country=schoolCountry,
      school_city=schoolCity, school_class=schoolClass, school=schoolVal, 
      school_year=schoolYear, religion=religionVal, interests=interestVal,
      company=complanyVal, position=positionVal, group_id=groupId, from_list=fromList})
end

function luaVkApi.isAppUser(userId)
  return luaVkApi.invokeApi("users.isAppUser", {user_id=userId})
end

function luaVkApi.getSubscriptions(userId, extendedVal, offsetVal, countVal, fieldsVal)
  return luaVkApi.invokeApi("users.getSubscriptions", {user_id=userId, extended=extendedVal,
      offset=offsetVal, count=countVal, fields=fieldsVal})
end

function luaVkApi.getFollowers(userId, nameCase, offsetVal, countVal, fieldsVal)
  return luaVkApi.invokeApi("users.getFollowers", {user_id=userId, name_case=nameCase,
      offset=offsetVal, count=countVal, fields=fieldsVal})
end

function luaVkApi.reportUser(userId, typeVal, commentVal)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  return luaVkApi.invokeApi("users.report", {user_id=userId, type=typeVal, comment=commentVal})
end

function luaVkApi.getNearbyUsers(latitudeVal, longitudeVal, accuracyVal, timeoutVal, radiusVal,
    fieldsVal, nameCaseVal)
  if not latitudeVal then
    return requiredParameterMsg .. " latitudeVal"
  end
  if not longitudeVal then
    return requiredParameterMsg .. " longitudeVal"
  end
  return luaVkApi.invokeApi("users.getNearby", {latitude=latitudeVal, longitude=longitudeVal,
      accuracy=accuracyVal, timeout=timeoutVal, radius=radiusVal, fields=fieldsVal,
      name_case=nameCase})
end

-----------------------
--  Authorization    --
-----------------------
function luaVkApi.checkPhone(phoneNumber, userId, clientSecret)
  if not phoneNumber then
    return requiredParameterMsg .. " phoneNumber"
  end
  if not clientSecret then
    return requiredParameterMsg .. " clientSecret"
  end
  return luaVkApi.invokeApi("auth.checkPhone", {phone=phoneNumber, client_id=userId,
      client_secret=clientSecret})
end

function luaVkApi.signup(firstName, lastName, clientId, clientSecret, phoneVal,
    passwordVal, testMode, voiceVal, sexVal, sidVal)
  if not firstName then
    return requiredParameterMsg .. " firstName"
  end
  if not lastName then
    return requiredParameterMsg .. " lastName"
  end
  if not clientId then
    return requiredParameterMsg .. " clientId"
  end
  if not clientSecret then
    return requiredParameterMsg .. " clientSecret"
  end
  if not phoneVal then
    return requiredParameterMsg .. " phoneVal"
  end  
  return luaVkApi.invokeApi("auth.signup", {first_name=firstName, last_name=lastName,
      client_id=clientId, client_secret=clientSecret, phone=phoneVal, password=passwordVal,
      test_mode=testMode, voice=voiceVal, sex=sexVal, sid=sidVal})
end

function luaVkApi.confirm(userId, clientSecret, phoneNumber, codeVal, passwordVal,
    testMode, introVal)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  if not clientSecret then
    return requiredParameterMsg .. " clientSecret"
  end
  if not phoneNumber then
    return requiredParameterMsg .. " phoneNumber"
  end
  if not codeVal then
    return requiredParameterMsg .. " codeVal"
  end
  return luaVkApi.invokeApi("auth.confirm", {client_id=userId, client_secret=clientSecret,
      phone=phoneNumber, code=codeVal, password=passwordVal, test_mode=testMode,
      intro=introVal})
end

function luaVkApi.restore(phoneNumber)
  if not phoneNumber then
    return requiredParameterMsg .. " phoneNumber"
  end
  return luaVkApi.invokeApi("auth.restore", {phone=phoneNumber})
end

-----------------------
--       Wall        --
-----------------------
function luaVkApi.getWallPosts(ownerId, domainVal, offsetVal, countVal, filterVal,
    isExtended, fieldsVal)
  return luaVkApi.invokeApi("wall.get", {owner_id=ownerId, domain=domainVal,
      offset=offsetVal, count=countVal, filter=filterVal, extended=isExtended,
      fields=fieldsVal})
end

function luaVkApi.searchWallPosts(ownerId, domainVal, queryStr, offsetVal, countVal,
    ownersOnly, filterVal, isExtended, fieldsVal)
  return luaVkApi.invokeApi("wall.search", {owner_id=ownerId, domain=domainVal,
      query=queryStr, offset=offsetVal, count=countVal, owners_only=ownersOnly,
      filter=filterVal, extended=isExtended, fields=fieldsVal})
end

function luaVkApi.getWallById(postIds, isExtended, copyHistoryDepth, fieldsVal)
  if not postIds then
    return requiredParameterMsg .. " postIds"
  end
  return luaVkApi.invokeApi("wall.getById", {posts=postIds, extended=isExtended,
      copy_history_depth=copyHistoryDepth, fields=fieldsVal})
end

function luaVkApi.post(ownerId, friendsOnly, fromGroup, messageVal, postAttachments,
    servicesList, isSigned, publishDate, latitude, longitude, placeId, postId)
  return luaVkApi.invokeApi("wall.post", {owner_id=ownerId, friends_only=friendsOnly,
      from_group=fromGroup, message=messageVal, attachments=postAttachments,
      services=servicesList, signed=isSigned, publish_date=publishDate, lat=latitude,
      long=longitude, place_id=placeId, post_id=postId})
end

function luaVkApi.doRepost(objectId, messageStr, groupId, refVal)
  if not objectId then
    return requiredParameterMsg .. " objectId"
  end
  return luaVkApi.invokeApi("wall.repost", {object=objectId, message=messageStr,
      group_id=groupId, ref=refVal})
end

function luaVkApi.getReposts(ownerId, postId, offsetVal, countVal)
  return luaVkApi.invokeApi("wall.getReposts", {owner_id=ownerId, post_id=postId,
      offset=offsetVal, count=countVal})
end

function luaVkApi.editPost(ownerId, postId, friendsOnly, messageVal, postAttachments,
    servicesList, isSigned, publishDate, latitude, longitude, placeId)
  return luaVkApi.invokeApi("wall.edit", {owner_id=ownerId, post_id=postId, 
      friends_only=friendsOnly, message=messageVal, attachments=postAttachments,
      services=servicesList, signed=isSigned, publish_date=publishDate, lat=latitude,
      long=longitude, place_id=placeId})
end

function luaVkApi.deletePost(ownerId, postId)
  return luaVkApi.invokeApi("wall.delete", {owner_id=ownerId, post_id=postId})
end

function luaVkApi.restorePost(ownerId, postId)
  return luaVkApi.invokeApi("wall.restore", {owner_id=ownerId, post_id=postId})
end

function luaVkApi.pinPost(ownerId, postId)
  if not postId then
    return requiredParameterMsg .. " postId"
  end
  return luaVkApi.invokeApi("wall.pin", {owner_id=ownerId, post_id=postId})
end

function luaVkApi.unpinPost(ownerId, postId)
  if not postId then
    return requiredParameterMsg .. " postId"
  end
  return luaVkApi.invokeApi("wall.unpin", {owner_id=ownerId, post_id=postId})
end

function luaVkApi.getComments(ownerId, postId, needLikes, startCommentId, offsetVal,
    countVal, sortVal, previewLength, isExtened)
  if not postId then
    return requiredParameterMsg .. " postId"
  end
  return luaVkApi.invokeApi("wall.getComments", {owner_id=ownerId, post_id=postId, 
      need_likes=needLikes, start_comment_id=startCommentId, offset=offsetVal,
      count=countVal, sort=sortVal, preview_length=previewLength, extended=isExtened})
end

function luaVkApi.addComment(ownerId, postId, fromGroup, textVal, replyToComment,
    commentAttachments, stickerId, refVal)
  if not postId then
    return requiredParameterMsg .. " postId"
  end
  return luaVkApi.invokeApi("wall.addComment", {owner_id=ownerId, post_id=postId, 
      from_group=fromGroup, text=textVal, reply_to_comment=replyToComment,
      attachments=commentAttachments, sticker_id=stickerId, ref=refVal})
end

function luaVkApi.editComment(ownerId, commentId, messageVal, commentAttachments)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("wall.editComment", {owner_id=ownerId, comment_id=commentId, 
      message=messageVal, reply_to_comment=replyToComment, attachments=commentAttachments})
end

function luaVkApi.deleteComment(ownerId, commentId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("wall.deleteComment", {owner_id=ownerId, comment_id=commentId})
end

function luaVkApi.restoreComment(ownerId, commentId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("wall.restoreComment", {owner_id=ownerId, comment_id=commentId})
end

function luaVkApi.reportPost(ownerId, postId, reasonVal)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not postId then
    return requiredParameterMsg .. " postId"
  end
  return luaVkApi.invokeApi("wall.reportPost", {owner_id=ownerId, post_id=postId,
      reason=reasonVal})
end

function luaVkApi.reportComment(ownerId, commentId, reasonVal)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("wall.reportComment", {owner_id=ownerId, comment_id=commentId,
      reason=reasonVal})
end

-----------------------
--     Photos        --
-----------------------
function luaVkApi.createPhotoAlbum(titleVal, groupId, descriptionVal, privacyView,
    privacyComment, uploadByAdminsOnly, commentsDissabled)
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("photos.createAlbum", {title=titleVal, grop_id=groupId,
      description=descriptionVal, privacy_view=privacyView, privacy_comment=privacyComment,
      upload_by_admins_only=uploadByAdminsOnly, comments_dissabled=commentsDissabled})
end

function luaVkApi.editPhotoAlbum(albumId, titleVal, descriptionVal, ownerId, privacyView,
    privacyComment, uploadByAdminsOnly, commentsDissabled)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  return luaVkApi.invokeApi("photos.editAlbum", {album_id=albumId, title=titleVal,
      description=descriptionVal, owner_id=ownerId, privacy_view=privacyView, 
      privacy_comment=privacyComment, upload_by_admins_only=uploadByAdminsOnly, 
      comments_dissabled=commentsDissabled})
end

function luaVkApi.getPhotoAlbums(ownerId, albumIds, offsetVal, countVal, needSystem,
    needCovers, photoSizes)
  return luaVkApi.invokeApi("photos.getAlbums", {owner_id=ownerId, album_ids=albumIds,
      offset=offsetVal, count=countVal, need_system=needSystem, need_covers=needCovers,
      photo_sizes=photoSizes})
end

function luaVkApi.getPhotos(ownerId, albumId, photoIds, revVal, isExtended, feedType,
    feedVal, photoSizes, offsetVal, countVal)
  return luaVkApi.invokeApi("photos.get", {owner_id=ownerId, album_id=albumId,
      photo_ids=photoIds, rev=revVal, extended=isExtended, feed_type=feedType,
      feed=feedVal, photo_sizes=photoSizes, offset=offsetVal, count=countVal})
end

function luaVkApi.getPhotoAlbumsCount(userId, groupId)
  return luaVkApi.invokeApi("photos.getAlbumsCount", {user_id=userId, group_id=groupId})
end

function luaVkApi.getPhotosById(photosVal, isExtended, photoSizes)
  return luaVkApi.invokeApi("photos.getById", {photos=photosVal, extended=isExtended,
      photo_sizes=photoSizes})
end

function luaVkApi.getPhotoUploadServer(albumId, groupId)
  return luaVkApi.invokeApi("photos.getUploadServer", {album_id=albumId, group_id=groupId})
end

function luaVkApi.getOwnerPhotoUploadServer(ownerId)
  return luaVkApi.invokeApi("photos.getOwnerPhotoUploadServer", {owner_id=ownerId})
end

function luaVkApi.getChatCoverUploadServer(chatId, cropX, cropY, cropWidth)
  if not chatId then
    return requiredParameterMsg .. " chatId"
  end
  return luaVkApi.invokeApi("photos.getChatUploadServer", {chat_id=chatId, crop_x=cropX,
      crop_y=cropY, crop_width=cropWidth})
end

function luaVkApi.saveOwnerPhoto(serverVal, hashVal, photoVal)
  return luaVkApi.invokeApi("photos.saveOwnerPhoto", {server=serverVal, hash=hashVal,
      photo=photoVal})
end 

function luaVkApi.saveWallPhoto(userId, groupId, photoVal, serverVal, hashVal)
  if not photoVal then
    return requiredParameterMsg .. " photoVal"
  end
  return luaVkApi.invokeApi("photos.saveWallPhoto", {user_id=userId, group_id=grouId,
      photo=photoVal, server=serverVal, hash=hashVal})
end

function luaVkApi.getWallPhotoUploadServer(groupId)
  return luaVkApi.invokeApi("photos.getWallUploadServer", {group_id=grouId})
end

function luaVkApi.getMessagesUploadServer()
  return luaVkApi.invokeApi("photos.getMessagesUploadServer")
end

function luaVkApi.saveMessagesPhoto(photoVal)
  if not photoVal then
    return requiredParameterMsg .. " photoVal"
  end
  return luaVkApi.invokeApi("photos.saveMessagesPhoto", {photo=photoVal})
end

function luaVkApi.reportPhoto(ownerId, photoId, reasonVal)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.report", {owner_id=ownerId, photo_id=photoId,
      reason=reasonVal})
end

function luaVkApi.reportPhotoComment(ownerId, commentId, reasonVal)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("photos.reportComment", {owner_id=ownerId, comment_id=commentId,
      reason=reasonVal})
end

function luaVkApi.searchPhotos(query, latitude, longitude, startTime, endTime, sortVal,
    offsetVal, countVal, radiusVal)
  return luaVkApi.invokeApi("photos.search", {q=query, lat=latitude, long=longitude,
      start_time=startTime, end_time=endTime, sort=sortVal, offset=offsetVal,
      count=countVal, radius=radiusVal})
end

function luaVkApi.savePhoto(albumId, groupId, serverVal, photosList, hashVal,
    latitudeVal, longitudeVal, captionVal)
  return luaVkApi.invokeApi("photos.save", {album_id=albumId, group_id=groupId,
  server=serverVal, photos_list=photosList, hash=hashVal, latitude=latitudeVal,
  longitude=longitudeVal, caption=captionVal})
end

function luaVkApi.copyPhoto(ownerId, photoId, accessKey)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.copy", {owner_id=ownerId, photo_id=photoId, 
      access_key=accessKey})
end

function luaVkApi.editPhoto(ownerId, photoId, captionVal, latitudeVal, longitudeVal,
    placeStr, foursquareId, deletePlace)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.edit", {owner_id=ownerId, photo_id=photoId,
      caption=captionVal, latitude=latitudeVal, longitude=longitudeVal,
      place_str=placeStr, foursquare_id=foursquareId, delete_place=deletePlace})
end

function luaVkApi.movePhoto(ownerId, targetAlbumId, photoId)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  if not targetAlbumId then
    return requiredParameterMsg .. " targetAlbumId"
  end
  return luaVkApi.invokeApi("photos.move", {owner_id=ownerId, target_album_id=targetAlbumId,
      photo_id=photoId})
end

function luaVkApi.makeCover(ownerId, photoId, albumId)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.makeCover", {owner_id=ownerId, photo_id=photoId,
      album_id=albumId})
end

function luaVkApi.reorderPhotoAlbums(ownerId, albumId, beforeVal, afterVal)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  return luaVkApi.invokeApi("photos.reorderAlbums", {owner_id=ownerId, album_id=albumId,
      before=beforeVal, after=afterVal})
end

function luaVkApi.reorderPhotos(ownerId, photoId, beforeVal, afterVal)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.reorderPhotos", {owner_id=ownerId, photo_id=photoId,
      before=beforeVal, after=afterVal})
end

function luaVkApi.getAllPhotos(ownerId, isExtended, offsetVal, countVal, photoSizes,
    noServiceAlbums, needHidden, skipHidden)
  return luaVkApi.invokeApi("photos.getAll", {owner_id=ownerId, extended=isExtended,
      offset=offsetVal, count=countVal, photo_sizes=photoSizes, no_service_albums=noServiceAlbums,
      need_hidden=needHidden, skip_hidden=skipHidden})
end

function luaVkApi.getUserPhotos(userId, offsetVal, countVal, isExtended, sortVal)
  return luaVkApi.invokeApi("photos.getUserPhotos", {user_id=userId, offset=offsetVal,
      count=countVal, extended=isExtended, sort=sortVal})
end

function luaVkApi.deletePhotoAlbum(albumId, groupId)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  return luaVkApi.invokeApi("photos.deleteAlbum", {album_id=albumId, group_id=groupId})
end

function luaVkApi.deletePhoto(ownerId, photoId)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.delete", {owner_id=ownerId, photo_id=photoId})
end

function luaVkApi.restorePhoto(ownerId, photoId)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.restore", {owner_id=ownerId, photo_id=photoId})
end

function luaVkApi.confirmPhotoTag(ownerId, photoId, tagId)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  if not tagId then
    return requiredParameterMsg .. " tagId"
  end
  return luaVkApi.invokeApi("photos.confirmTag", {owner_id=ownerId, photo_id=photoId,
      tag_id=tagId})
end

function luaVkApi.getNewPhotoTags(offsetVal, countVal)
  return luaVkApi.invokeApi("photos.getNewTags", {offset=offsetVal, count=countVal})
end

function luaVkApi.removePhotoTag(ownerId, photoId, tagId)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  if not tagId then
    return requiredParameterMsg .. " tagId"
  end
  return luaVkApi.invokeApi("photos.removeTag", {owner_id=ownerId, photo_id=photoId,
      tag_id=tagId})
end

function luaVkApi.putPhotoTag(ownerId, photoId, userId, x_, y_, x2_, y2_)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("photos.putTag", {owner_id=ownerId, photo_id=photoId,
      user_id=userId, x=x_, y=y_, x2=x2_, y2=y2_})
end

function luaVkApi.gePhotoTags(ownerId, photoId, accessKey)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.getTags", {owner_id=ownerId, photo_id=photoId,
      access_key=accessKey})
end

function luaVkApi.gePhotoComments(ownerId, photoId, needLikes, startCommentId, offsetVal,
    countVal, sortVal, accessKey, isExtended, fieldsVal)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  return luaVkApi.invokeApi("photos.getComments", {owner_id=ownerId, photo_id=photoId,
      need_likes=needLikes, start_comment_id=startCommentId, offset=offsetVal,
      count=countVal, sort=sortVal, access_key=accessKey, extended=isExtended,
      fields=fieldsVal})
end

function luaVkApi.getAllPhotoComments(ownerId, albumId, needLikes, offsetVal, countVal)
  return luaVkApi.invokeApi("photos.getAllComments", {owner_id=ownerId, album_id=albumId,
      need_likes=needLikes, offset=offsetVal, count=countVal})
end

function luaVkApi.createPhotoComment(ownerId, photoId, messageStr, attachmentsVal, fromGroup,
    replyToComment, stickerId, accessKey, guidVal)
  if not photoId then
    return requiredParameterMsg .. " photoId"
  end
  if not messageStr or not attachmentsVal then
    return requiredParameterMsg .. " attachmentsVal or messageStr"
  end
  return luaVkApi.invokeApi("photos.createComment", {owner_id=ownerId, photo_id=photoId,
      message=messageStr, attachments=attachmentsVal, from_group=fromGroup,
      reply_to_comment=replyToComment, sticker_id=stickerId, access_key=accessKey,
      guid=guidVal})
end

function luaVkApi.deletePhotoComment(ownerId, commentId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("photos.deleteComment", {owner_id=ownerId, comment_id=commentId})
end

function luaVkApi.restorePhotoComment(ownerId, commentId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("photos.restoreComment", {owner_id=ownerId, comment_id=commentId})
end

function luaVkApi.editPhotoComment(ownerId, commentId, messageVal, attachmentsVal)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  if not messageVal or not attachmentsVal then
    return requiredParameterMsg .. " attachmentsVal or messageStr"
  end
  return luaVkApi.invokeApi("photos.editComment", {owner_id=ownerId, comment_id=commentId,
      message=messageVal, attachments=attachmentsVal})
end
-----------------------
--     Friends       --
-----------------------
function luaVkApi.getFriendIds(userId, orderVal, listId, countVal, offsetVal, 
    fieldsVal, nameCase)
  return luaVkApi.invokeApi("friends.get", {user_id=userId, order=orderVal, list_id=listId, 
      count=countVal, offset=offsetVal, fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.addToFriends(userId, textVal, followVal)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("friends.add", {user_id=userId, text=textVal, follow=followVal})
end

function luaVkApi.getOnlineFriends(userId, listId, onlineMobile, sortOrder, countVal, offsetVal)
  return luaVkApi.invokeApi("friends.getOnline", {user_id=userId, list_id=listId,
      online_mobile=onlineMobile, order=sortOrder, count=countVal, offset=offsetVal})
end

function luaVkApi.getMutualFriends(sourceUid, targetUid, targetUids, sortOrder,
    countVal, offsetVal)
  return luaVkApi.invokeApi("friends.getMutual", {source_uid=sourceUid, target_uid=targetUid,
      target_uids=targetUids, order=sortOrder, count=countVal, offset=offsetVal})
end

function luaVkApi.getRecentFriends(countVal)
  return luaVkApi.invokeApi("friends.getRecent", {count=countVal})
end

function luaVkApi.getFriendsRequests(countVal, offsetVal, extended, needMutual, outVal, sortVal,
    suggestedVal)
  return luaVkApi.invokeApi("friends.getRequests", {count=countVal, offset=offsetVal, 
      extended=extendedVal, need_mutual=needMutual, out=outVal, sort=sortVal, suggested=suggestedVal})
end

function luaVkApi.editFriendsList(userId, listIds)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("friends.edit", {user_id=userId, list_ids=listIds})
end

function luaVkApi.deleteFriend(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("friends.delete", {user_id=userId})
end

function luaVkApi.getFriendsOfFriendsIds(userId, returnSystem)
  return luaVkApi.invokeApi("friends.getLists", {user_id=userId, return_system=returnSystem})
end

function luaVkApi.addFriendList(nameVal, userIds)
  if not nameVal then
    return requiredParameterMsg .. " nameVal"
  end
  return luaVkApi.invokeApi("friends.addList", {name=nameVal, user_ids=userIds})
end

function luaVkApi.editFriendList(nameVal, listId, userIds, addUserIds, deleteUserIds)
  if not listId then
    return requiredParameterMsg .. " listId"
  end
  return luaVkApi.invokeApi("friends.editList", {name=nameVal, list_id=listId, user_ids=userIds,
      add_user_ids=addUserIds, delete_user_ids=deleteUserIds})
end

function luaVkApi.deleteFriendList(listId)
  if not listId then
    return requiredParameterMsg .. " listId"
  end
  return luaVkApi.invokeApi("friends.deleteList", {list_id=listId})
end

function luaVkApi.getAppUsers()
  return luaVkApi.invokeApi("friends.getAppUsers")
end

function luaVkApi.getUsersByPhones(phonesVal, fieldsVal)
  return luaVkApi.invokeApi("friends.getByPhones", {phones=phonesVal, fields=fieldsVal})
end

function luaVkApi.deleteAllFriendsRequests()
  return luaVkApi.invokeApi("friends.deleteAllRequests")
end

function luaVkApi.getFriendsSuggestions(filterVal, countVal, offsetVal,fieldsVal, nameCase)
  return luaVkApi.invokeApi("friends.getSuggestions", {filter=filterVal, count=countVal,
      offset=offsetVal, fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.areFriends(userIds, needSign)
  if not userIds then
    return requiredParameterMsg .. " userIds"
  end
  return luaVkApi.invokeApi("friends.areFriends", {user_ids=userIds, need_sign=needSign})
end

function luaVkApi.getAvailableFriendsForCall(fieldsVal, nameCase)
  return luaVkApi.invokeApi("friends.getAvailableForCall", {fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.searchFriends(userId, query, fieldsVal, nameCase, offsetVal, countCal)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("friends.search", {user_id=userId, q=query, fields=fieldsVal,
      name_case=nameCase, offset=offsetVal, count=countVal})
end

-----------------------
--     Widgets       --
-----------------------
function luaVkApi.getCommentsFromWidget(widgetApiId, urlStr, pageId, orderVal,
    fieldsVal, offsetVal, countCal)
  return luaVkApi.invokeApi("widgets.getComments", {widget_api_id=widgetApiId, url=urlStr,
      page_id=pageId, order=orderVal, fields=fieldsVal, offset=offsetVal, count=countVal})
end

function luaVkApi.getPagesWithWidget(widgetApiId, orderVal, periodVal, offsetVal, countCal)
  return luaVkApi.invokeApi("widgets.getPages", {widget_api_id=widgetApiId, order=orderVal,
      page_id=pageId, order=orderVal, period=periodVal, offset=offsetVal, count=countVal})
end

-----------------------
--    Data storage   --
-----------------------
function luaVkApi.getStorageVariable(keyStr, keysStr, userId, globalVal)
  return luaVkApi.invokeApi("storage.get", {key=keyStr, keys=keysStr, user_id=userId,
      global=globalVal})
end

function luaVkApi.setStorageVariable(keyStr, valueStr, userId, globalVal)
  if not keyStr then
    return requiredParameterMsg .. " keyStr"
  end
  return luaVkApi.invokeApi("storage.set", {key=keyStr, value=valueStr, user_id=userId,
      global=globalVal})
end

function luaVkApi.getVariableKeys(userId, globalVal, offsetVal, countVal)
  return luaVkApi.invokeApi("storage.getKeys", {user_id=userId, global=globalVal,
      offset=offsetVal, count=countVal})
end

-----------------------
--      Status       --
-----------------------
function luaVkApi.getStatus(userId, groupId)
  return luaVkApi.invokeApi("status.get", {user_id=userId, group_id=groupId})
end

function luaVkApi.setStatus(textVal, groupId)
  return luaVkApi.invokeApi("status.set", {text=textVal, group_id=groupId})
end

-----------------------
--    Audio files    --
-----------------------
function luaVkApi.getAudios(ownerId, albumId, audioIds, needUser, offsetVal, countVal)
  return luaVkApi.invokeApi("audio.get", {owner_id=ownerId, album_id=albumId,
      audio_ids=audioIds, need_user=needUser, offset=offsetVal, count=countVal})
end

function luaVkApi.getAudiosById(audioIds)
  if not audioIds then
    return requiredParameterMsg .. " audioIds"
  end
  return luaVkApi.invokeApi("audio.getById", {audios=audioIds})
end

function luaVkApi.getLyrics(lyricsId)
  if not lyricsId then
    return requiredParameterMsg .. " lyricsId"
  end
  return luaVkApi.invokeApi("audio.getLyrics", {lyrics_id=lyricsId})
end

function luaVkApi.searchAudios(query, autoComplete, lyricsVal, performerOnly, sortVal,
    searchOwn, offsetVal, countVal)
  return luaVkApi.invokeApi("audio.search", {q=query, auto_compleate=autoComplete,
      lyrics=lyricsVal, performer_only=performerOnly, sort=sortVal, search_own=searchOwn,
      offset=offsetVal, count=countVal})
end

function luaVkApi.getAudioUploadServer()
  return luaVkApi.invokeApi("audio.getUploadServer")
end

function luaVkApi.saveAudio(serverVal, audioVal, hashVal, artistVal, titleVal)
  if not serverVal then
    return requiredParameterMsg .. " serverVal"
  end
  if not audioVal then
    return requiredParameterMsg .. " audioVal"
  end
  return luaVkApi.invokeApi("audio.save", {server=serverVal, audio=audioVal, hash=hashVal,
      artist=artistVal, title=titleVal})
end

function luaVkApi.addAudio(audioId, ownerId, groupId, albumId)
  if not audioId then
    return requiredParameterMsg .. " audioId"
  end
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  return luaVkApi.invokeApi("audio.add", {audio_id=audioId, owner_id=ownerId, group_id=groupId,
      album_id=albumId})
end

function luaVkApi.deleteAudio(audioId, ownerId)
  if not audioId then
    return requiredParameterMsg .. " audioId"
  end
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  return luaVkApi.invokeApi("audio.delete", {audio_id=audioId, owner_id=ownerId})
end

function luaVkApi.editAudio(ownerId, audioId, artistVal, titleVal, textVal, genreId, noSearch)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not audioId then
    return requiredParameterMsg .. " audioId"
  end
  return luaVkApi.invokeApi("audio.edit", {owner_id=ownerId, audio_id=audioId, artist=artistVal,
      title=titleVal, text=textVal, genre_id=genreId, no_search=noSearch})
end

function luaVkApi.reorderAudio(audioId, ownerId, beforeVal, afterVal)
  if not audioId then
    return requiredParameterMsg .. " audioId"
  end
  return luaVkApi.invokeApi("audio.reorder", {audio_id=audioId, owner_id=ownerId, before=beforeVal,
      after=afterVal})
end

function luaVkApi.restoreAudio(audioId, ownerId)
  if not audioId then
    return requiredParameterMsg .. " audioId"
  end
  return luaVkApi.invokeApi("audio.restore", {audio_id=audioId, owner_id=ownerId})
end

function luaVkApi.getAudioAlbums(ownerId, offsetVal, countVal)
  return luaVkApi.invokeApi("audio.getAlbums", {owner_id=ownerId, offset=offsetVal,
      count=countVal})
end

function luaVkApi.addAudioAlbum(groupId, titleVal)
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("audio.addAlbum", {group_id=groupId, title=titleVal})
end

function luaVkApi.editAudioAlbum(groupId, albumId, titleVal)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("audio.editAlbum", {group_id=groupId, album_id=albumId,
      title=titleVal})
end

function luaVkApi.deleteAudioAlbum(groupId, albumId)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  return luaVkApi.invokeApi("audio.deleteAlbum", {group_id=groupId, album_id=albumId})
end

function luaVkApi.moveAudioToAlbum(groupId, albumId, audioIds)
  if not audioIds then
    return requiredParameterMsg .. " audioIds"
  end
  return luaVkApi.invokeApi("audio.moveToAlbum", {group_id=groupId, album_id=albumId,
      audio_ids=audioIds})
end

function luaVkApi.setAudioBroadcast(audioVal, targetIds)
  return luaVkApi.invokeApi("audio.setBroadcast", {audio=audioVal, target_ids=targetIds})
end

function luaVkApi.getAudioBroadcastList(filterVal, isActive)
  return luaVkApi.invokeApi("audio.getBroadcastList", {filter=filterVal,active=isActive})
end

function luaVkApi.getAudioRecommendations(targetAudio, userId, offsetVal, countVal, isShuffle)
  return luaVkApi.invokeApi("audio.getRecommendations", {target_audio=targetAudio, user_id=userId,
      offset=offsetVal, count=countVal, shuffle=isShuffle})
end

function luaVkApi.getPopularAudios(onlyEng, genreId, offsetVal, countVal)
  return luaVkApi.invokeApi("audio.getPopular", {only_eng, genre_id, offset=offsetVal,
      count=countVal})
end

function luaVkApi.getAudiosCount(ownerId)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  return luaVkApi.invokeApi("audio.getCount", {owner_id=ownerId})
end

-----------------------
--       Pages       --
-----------------------
function luaVkApi.getPages(ownerId, pageId, isGlobal, sitePreview, titleVal, needSource,
    needHtml)
  return luaVkApi.invokeApi("pages.get", {owner_id=ownerId, page_id=pageId, global=isGlobal,
      site_preview=sitePreview, title=titleVal, need_source=needSource, need_html=needHtml})
end

function luaVkApi.savePage(textVal, pageId, groupId, userId, titleVal)
  return luaVkApi.invokeApi("pages.save", {text=textVal, page_id=pageId, group_id=groupId,
      user_id=userId, title=titleVal})
end

function luaVkApi.savePageAccess(pageId, groupId, userId, viewVal, editVal)
  if not pageId then
    return requiredParameterMsg .. " pageId"
  end
  return luaVkApi.invokeApi("pages.saveAccess", {page_id=pageId, group_id=groupId, user_id=userId,
      view=viewVal, edit=editVal})
end

function luaVkApi.getPageHistory(pageId, groupId, userId)
  if not pageId then
    return requiredParameterMsg .. " pageId"
  end
  return luaVkApi.invokeApi("pages.getHistory", {page_id=pageId, group_id=groupId, user_id=userId})
end

function luaVkApi.getPageTitles(groupId)
  return luaVkApi.invokeApi("pages.getTitles", {group_id=groupId})
end

function luaVkApi.getPageVersion(versionId, groupId, userId, needHtml)
  if not versionId then
    return requiredParameterMsg .. " versionId"
  end
  return luaVkApi.invokeApi("pages.getVersion", {version_id=versionId, group_id=groupId,
      user_id=userId, need_html=needHtml})
end

function luaVkApi.parseWiki(textVal, groupId)
  if not textVal then
    return requiredParameterMsg .. " textVal"
  end
  return luaVkApi.invokeApi("pages.parseWiki", {text=textVal, group_id=groupId})
end

function luaVkApi.clearPageCache(urlVal)
  if not textVal then
    return requiredParameterMsg .. " textVal"
  end
  return luaVkApi.invokeApi("pages.clearCache", {url=urlVal})
end

-----------------------
--    Communities    --
-----------------------
function luaVkApi.isCommunityMember(groupId, userId, userIds, isExtended)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.isMember", {group_id=groupId, user_id=userId,
        user_ids=userIds, extended=isExtended})
end

function luaVkApi.getCommunitiesById(groupIds, groupId, fieldsVal)
  return luaVkApi.invokeApi("groups.getById", {group_ids=groupIds, group_id=group_Id,
      fields=fieldsVal})
end

function luaVkApi.getCommunities(userId, isExtended, filterVal, fieldsVal,
    offsetVal, countVal)
  return luaVkApi.invokeApi("groups.get", {user_id=groupId, extended=isExtended,
      filter=filterVal, fields=fieldsVal, offset=offsetVal, count=countVal})
end

function luaVkApi.getCommunityMembers(groupId, sortVal, offsetVal, countVal,
    fieldsVal, filterVal)
  return luaVkApi.invokeApi("groups.getMembers", {group_id=groupId, sort=sortVal,
      offset=offsetVal, count=countVal, fields=fieldsVal, filter=filterVal})
end

function luaVkApi.joinCommunity(groupId, notSure)
  return luaVkApi.invokeApi("groups.join", {group_id=groupId, not_sure=notSure})
end

function luaVkApi.leaveCommunity(groupId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.leave", {group_id=groupId})
end

function luaVkApi.searchCommunities(query, typeVal, countryId, cityId, 
    isFuture, sortVal, offsetVal, countVal)
  if not query then
    return requiredParameterMsg .. " query"
  end
  return luaVkApi.invokeApi("groups.search", {q=query, type=typeVal, country_id=countryId,
      city_id=cityId, future=isFuture, sort=sortVal, offset=offsetVal, count=countVal})
end

function luaVkApi.getCommunitiesInvites(offsetVal, countVal, isExtended)
  return luaVkApi.invokeApi("groups.getInvites", {offset=offsetVal, count=countVal,
      extended=isExtended})
end

function luaVkApi.getInvitedUsers(groupId, offsetVal, countVal, fieldsVal, nameCase)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.getInvitedUsers", {group_id=groupId, offset=offsetVal,
      count=countVal, fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.banUserForCommunity(groupId, userId, endDate, reasonVal, commentVal,
    commentVisible)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("groups.banUser", {group_id=groupId, user_id=userId, 
    end_date=endDate, reason=reasonVal, comment=commentVal, 
    comment_visible=commentVisible})
end

function luaVkApi.unbanUserForCommunity(groupId, userId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("groups.unbanUser", {group_id=groupId, user_id=userId})
end

function luaVkApi.getBannedUsersForCommunity(groupId, ofsetVal, countVal, fieldsVal,
    userId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.getBanned", {group_id=groupId, offset=offsetVal, 
      count=countVal, fields=fieldsVal, user_id=userId})
end

function luaVkApi.createCommunity(titleVal, descriptionVal, typeVal, subtypeVal)
  return luaVkApi.invokeApi("groups.create", {title=titleVal, description=descriptionVal,
      type=typeVal, subtype=subtypeVal})
end

function luaVkApi.editCommunity(groupId, titleVal, descriptionVal, screenname,
    accessVal, websiteVal, subjectVal, emailVal, phoneVal, rssVal, eventStartDate, 
    eventFinishDate, eventGroupId, publicCategory, publicSubcategory, publicDate,
    wallVal, topicsVal, photosVal, videoVal, audioVal, linksVal, eventsVal, placesVal,
    contactsVal, docsVal, wikiVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.edit", {group_id=groupId, title=titleVal, 
      description=descriptionVal, screen_name=screenName, access=accessVal,
      website=sebsiteVal, subject=subjectVal, email=emailVal, phone=phoneVal, rss=rssVal,
      event_start_date=eventStartDate, event_finish_date=eventFinishDate,
      event_group_id=eventGroupId, public_category=publicCategory, 
      public_subcategory=publicSubcategory, public_date=publicDate, wall=wallVal,
      topics=topicsVal, photos=photosVal, video=videoVal, audio=audioVal, links=linksVal,
      events=eventsVal, places=placesVal, contacts=contactsVal, docs=docsVal,
      wiki=wikiVal})
end

function luaVkApi.editPlace(groupId, titleVal, adressVal, countryId, cityId, latitudeVal,
    longitudeVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.editPlace", {group_id=groupId, title=titleVal, 
      adress=adressVal, country_id=countryId, city_id=cityId, latitude=latitudeVal,
      longitude=longitudeVal})
end

function luaVkApi.getCommunitySettings(groupId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.getSettings", {group_id=groupId})
end

function luaVkApi.getCommunityRequests(groupId, offsetVal, countVal, fieldsVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("groups.getRequests", {group_id=groupId, offset=offsetVal,
      count=countVal, fields=fieldsVal})
end

function luaVkApi.editCommunityManager(groupId, userId, roleVal, isContact, 
    contactPosition, contactPhone, contactEmail)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("groups.editManager", {group_id=groupId, user_id=userId,
      role=roleVal, is_contact=isContact, contact_position=contactPosition,
      contact_phone=contactPhone, contact_email=contactEmail})
end

function luaVkApi.inviteToCommunity(groupId, userId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("groups.invite", {group_id=groupId, user_id=userId})
end

function luaVkApi.addCommunityLink(groupId, linkVal, text)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not linkVal then
    return requiredParameterMsg .. " linkVal"
  end
  return luaVkApi.invokeApi("groups.addLink", {group_id=groupId, link=linkVal,
      text=textVal})
end

function luaVkApi.deleteCommunityLink(groupId, linkId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not linkId then
    return requiredParameterMsg .. " linkId"
  end
  return luaVkApi.invokeApi("groups.addLink", {group_id=groupId, link_id=linkId})
end

function luaVkApi.editCommunityLink(groupId, linkId, textVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not linkId then
    return requiredParameterMsg .. " linkId"
  end
  return luaVkApi.invokeApi("groups.editLink", {group_id=groupId, link_id=linkId,
      text=textVal})
end

function luaVkApi.reorderCommunityLink(groupId, linkId, afterVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not linkId then
    return requiredParameterMsg .. " linkId"
  end
  return luaVkApi.invokeApi("groups.reorderLink", {group_id=groupId, link_id=linkId,
      after=afterVal})
end

function luaVkApi.removeUserFromCommunity(groupId, userId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("groups.removeUser", {group_id=groupId, user_id=userId})
end

function luaVkApi.approveUserRequestToCommunity(groupId, userId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("groups.approveRequest", {group_id=groupId, user_id=userId})
end

-----------------------
--      Boards       --
-----------------------
function luaVkApi.getBoardTopics(groupId, topicIds, orderVal, offsetVal, countVal, 
    isExtended, previewVal, previewLength)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("board.getTopics", {group_id=groupId, topic_ids=topicIds,
      order=orderVal, offset=offsetVal, count=countVal, extended=isExtended,
      preview=previewVal, preview_length=previewLength})
end

function luaVkApi.getBoardComments(groupId, topicId, needLikes, startCommentId, offsetVal,
    countVal, isExtended, sortVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.getComments", {group_id=groupId, topic_id=topicId,
      need_likes=needLikes, start_comment_id=startCommentId, offset=offsetVal, count=countVal,
      extended=isExtended, sort=sortVal})
end

function luaVkApi.addBoardTopic(groupId, titleVal, textVal, fromGroup, attachmentsVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("board.addTopic", {group_id=groupId, title=titleVal,
      text=textVal, from_group=fromGroup, attachments=attachmentsVal})
end

function luaVkApi.addCommentToBoardTopic(groupId, topicId, textVal, attachmentsVal, fromGroup,
    sticketId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.addComment", {group_id=groupId, topic_id=topicId,
      text=textVal, attachments=attachmentsVal, from_group=fromGroup, sticker_id=stickerId})
end

function luaVkApi.deleteBoardTopic(groupId, topicId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.deleteTopic", {group_id=groupId, topic_id=topicId})
end

function luaVkApi.editBoardTopic(groupId, topicId, titleVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("board.editTopic", {group_id=groupId, topic_id=topicId,
      title=titleVal})
end

function luaVkApi.editBoardTopicComment(groupId, topicId, commentId, textVal, attachmentsVal)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  if not textVal or not attachmentsVal then
    return requiredParameterMsg .. " textVal or attachmentsVal"
  end
  return luaVkApi.invokeApi("board.editComment", {group_id=groupId, topic_id=topicId,
      comment_id=commentId, text=textVal, attachments=attachmentsVal})
end

function luaVkApi.restoreBoardTopicComment(groupId, topicId, commentId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("board.restoreComment", {group_id=groupId, topic_id=topicId,
      comment_id=commentId})
end

function luaVkApi.deleteBoardTopicComment(groupId, topicId, commentId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("board.deleteComment", {group_id=groupId, topic_id=topicId,
      comment_id=commentId})
end

function luaVkApi.openBoardTopic(groupId, topicId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.openTopic", {group_id=groupId, topic_id=topicId})
end

function luaVkApi.closeBoardTopic(groupId, topicId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.closeTopic", {group_id=groupId, topic_id=topicId})
end

function luaVkApi.fixBoardTopic(groupId, topicId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.fixTopic", {group_id=groupId, topic_id=topicId})
end

function luaVkApi.unfixBoardTopic(groupId, topicId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  if not topicId then
    return requiredParameterMsg .. " topicId"
  end
  return luaVkApi.invokeApi("board.unfixTopic", {group_id=groupId, topic_id=topicId})
end

-----------------------
--      Videos       --
-----------------------
function luaVkApi.getVideosInfo(ownerId, videoIds, albumId, countVal, offsetVal,
    isExtended)
  return luaVkApi.invokeApi("video.get", {owner_id=ownerId, videos=videoIds,
      album_id=albumId, count=countVal, offset=offsetVal, extended=isExtended})
end

function luaVkApi.editVideoInfo(ownerId, videoId, nameVal, descVal, privacyView,
    privacyComment, noComments)
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.edit", {owner_id=ownerId, video_id=videoId,
      name=nameVal, desc=descVal, privacy_view=privacyView, 
      privacy_comment=privacyComment, no_comments=noComments})
end

function luaVkApi.addVideo(targetId, videoId, ownerId)
  if not targetId then
    return requiredParameterMsg .. " targetId"
  end
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  return luaVkApi.invokeApi("video.add", {target_id=targetId, owner_id=ownerId,
      video_id=videoId})
end

function luaVkApi.saveVideo(nameVal, descVal, isPrivate, wallPost, linkVal,
    groupId, albumId, privacyView, privacyComment, noComments, isRepeat)
  return luaVkApi.invokeApi("video.save", {name=nameVal, description=descVal,
      is_private=isPrivate, wallpost=wallPost, link=linkVal, group_id=groupId,
      album_id=albumId, privacy_view=privacyView, privacy_comment=privacyComment,
      no_comments=noComments, is_repeat=isRepeat})
end

function luaVkApi.deleteVideo(videoId, ownerId, targetId)
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.delete", {video_id=videoId, owner_id=ownerId,
      target_id=targetId})
end

function luaVkApi.restoreVideo(videoId, ownerId)
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  return luaVkApi.invokeApi("video.restore", {video_id=videoId, owner_id=ownerId})
end

function luaVkApi.searchVideos(query, sortVal, isHD, isAdult, filtersVal, searchOwn,
    offsetVal, longerThan, shorterThan, countVal, isExtended)
  if not query then
    return requiredParameterMsg .. " query"
  end
  return luaVkApi.invokeApi("video.search", {q=query, sort=sortVal, hd=isHD,
      adult=isAdult, filters=filtersVal, search_own=searchOwn, offset=offsetVal,
      longer=longerThen, shorter=shorterThan, count=countVal, extended=isExtended})
end

function luaVkApi.getUserVideos(userId, offsetVal, countVal, isExtended)
  return luaVkApi.invokeApi("video.getUserVideos", {user_id=userId, offset=offsetVal, 
      count=countVal, extended=isExtended})
end

function luaVkApi.getVideoAlbums(ownerId, offsetVal, countVal, isExtended, needSystem)
  return luaVkApi.invokeApi("video.getAlbums", {owner_is=ownerId, offset=offsetVal, 
      count=countVal, extended=isExtended, need_system=needSystem})
end

function luaVkApi.getVideoAlbumById(ownerId, albumId)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  return luaVkApi.invokeApi("video.getAlbumById", {owner_is=ownerId, album_id=albumId})
end

function luaVkApi.addVideoAlbum(groupId, titleVal, privacyVal)
  return luaVkApi.invokeApi("video.addAlbum", {group_iid=groupId, title=titleVal,
      privacy=privacyVal})
end

function luaVkApi.editVideoAlbum(groupId, albumId, titleVal, privacyVal)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("video.editAlbum", {group_id=groupId, album_id=albumId, 
      title=titleVal, privacy=privacyVal})
end

function luaVkApi.deleteVideoAlbum(groupId, albumId)
  return luaVkApi.invokeApi("video.deleteAlbum", {group_id=groupId, album_id=albumId})
end

function luaVkApi.reorderVideoAlbums(ownerId, albumId, beforeVal, afterVal)
  if not albumId then
    return requiredParameterMsg .. " albumId"
  end
  return luaVkApi.invokeApi("video.reorderAlbums", {owner_id=ownerId, album_id=albumId,
      before=beforeVal, after=afterVal})
end

function luaVkApi.addVideoToAlbum(targetId, albumId, albumIds, ownerId, videoId)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.addToAlbum", {target_id=targetId, album_id=albumId,
      album_ids=albumIds, owner_id=ownerId, video_id=videoId})
end

function luaVkApi.removeVideoFromAlbum(targetId, albumId, albumIds, ownerId, videoId)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.removeFromAlbum", {target_id=targetId, album_id=albumId,
      album_ids=albumIds, owner_id=ownerId, video_id=videoId})
end

function luaVkApi.getAlbumsByVideo(targetId, ownerId, videoId, isExtended)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.getAlbumsByVideo", {target_id=targetId, owner_id=ownerId, 
      video_id=videoId, extended=isExtended})
end

function luaVkApi.getVideoComments(ownerId, videoId, needLikes, startCommentId, offsetVal,
    countVal, sortVal, isExtended)
  return luaVkApi.invokeApi("video.getComments", {owner_id=ownerId, video_id=videoId, 
      need_likes=needLikes, start_comment_id=startCommentId, offset=offsetVal,
      count=countVal, sort=sortVal, extended=isExtended})
end

function luaVkApi.createVideoComment(ownerId, videoId, messageVal, attachmentsVal,
    fromGroup, replyToComment, stickerId)
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.createComment", {owner_id=ownerId, video_id=videoId, 
      message=messageVal, attachments=attachmentsVal, from_group=gromGroup,
      reply_to_comment=replyToComment, sticker_id=stickerId})
end

function luaVkApi.deleteVideoComment(ownerId, commentId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("video.deleteComment", {owner_id=ownerId, comment_id=commentId})
end

function luaVkApi.restoreVideoComment(ownerId, commentId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("video.restoreComment", {owner_id=ownerId, comment_id=commentId})
end

function luaVkApi.editVideoComment(ownerId, commentId, messageVal, attachmentsVal)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("video.editComment", {owner_id=ownerId, comment_id=commentId,
      message=messageVal, attachments=attachmentsVal})
end

function luaVkApi.getVideoTags(ownerId, videoId)
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.getTags", {owner_id=ownerId, video_id=videoId})
end

function luaVkApi.putVideoTag(userId, ownerId, videoId, taggedName)
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.putTag", {user_id=userId, owner_id=ownerId, 
      video_id=videoId, tagged_name=taggedName})
end

function luaVkApi.removeVideoTag(tagId, ownerId, videoId)
  if not tagId then
    return requiredParameterMsg .. " tagId"
  end
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.removeTag", {tag_id=tagId, owner_id=ownerId, 
      video_id=videoId})
end

function luaVkApi.getNewVideoTags(offsetVal, countVal)
  return luaVkApi.invokeApi("video.getNewTags", {offset=offsetVal, count=countVal})
end

function luaVkApi.reportVideo(ownerId, videoId, reasonVal, commentVal, query)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not videoId then
    return requiredParameterMsg .. " videoId"
  end
  return luaVkApi.invokeApi("video.report", {owner_id=ownerId, video_id=videoId,
      reason=reasonVal, comment=commentVal, search_query=query})
end

function luaVkApi.reportVideoComment(ownerId, commentId, reasonVal)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("video.reportComment", {owner_id=ownerId, comment_id=commentId,
      reason=reasonVal})
end

-----------------------
--       Notes       --
-----------------------
function luaVkApi.getNotes(noteIds, userId, offsetVal, countVal, sortVal)
  return luaVkApi.invokeApi("notes.get", {note_ids=noteIds, user_id=userId,
      offset=offsetVal, count=countVal, sort=sortVal})
end

function luaVkApi.getNotesById(noteId, userId, needViki)
  return luaVkApi.invokeApi("notes.getById", {note_id=noteId, user_id=userId,
      need_wiki=needWiki})
end

function luaVkApi.getFriendsNotes(offsetVal, countVal)
  return luaVkApi.invokeApi("notes.getFriendsNotes", {offset=offsetVal, count=countVal})
end

function luaVkApi.addNote(titleVal, textVal, privacyView, privacyComment)
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  if not textVal then
    return requiredParameterMsg .. " textVal"
  end
  return luaVkApi.invokeApi("notes.add", {title=titleVal, text=textVal,
      privacy_view=privacyView, privacy_comment=privacyComment})
end

function luaVkApi.editNote(noteId, titleVal, textVal, privacyView, privacyComment)
  if not noteId then
    return requiredParameterMsg .. " noteId"
  end
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  if not textVal then
    return requiredParameterMsg .. " textVal"
  end
  return luaVkApi.invokeApi("notes.edit", {note_id=noteId, title=titleVal, text=textVal,
      privacy_view=privacyView, privacy_comment=privacyComment})
end

function luaVkApi.deleteNote(noteId)
  if not noteId then
    return requiredParameterMsg .. " noteId"
  end
  return luaVkApi.invokeApi("notes.delete", {note_id=noteId})
end

function luaVkApi.getNoteComments(noteId, ownerId, sortVal, offsetVal, countVal)
  if not noteId then
    return requiredParameterMsg .. " noteId"
  end
  return luaVkApi.invokeApi("notes.getComments", {note_id=noteId, owner_id=ownerId,
      sort=sortVal, offset=offsetVal, count=countVal})
end

function luaVkApi.createNoteComment(noteId, ownerId, replyTo, messageVal)
  if not noteId then
    return requiredParameterMsg .. " noteId"
  end
  if not messageVal then
    return requiredParameterMsg .. " messageVal"
  end
  return luaVkApi.invokeApi("notes.createComment", {note_id=noteId, owner_id=ownerId,
      reply_to=replyTo, message=messageVal})
end

function luaVkApi.editNoteComment(commentId, ownerId, messageVal)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("notes.editComment", {comment_id=commentId, owner_id=ownerId,
      message=messageVal})
end

function luaVkApi.deleteNoteComment(commentId, ownerId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("notes.deleteComment", {comment_id=commentId, owner_id=ownerId})
end 

function luaVkApi.restoreNoteComment(commentId, ownerId)
  if not commentId then
    return requiredParameterMsg .. " commentId"
  end
  return luaVkApi.invokeApi("notes.restoreComment", {comment_id=commentId, owner_id=ownerId})
end 

-----------------------
--      Places       --
-----------------------
function luaVkApi.addPlace(typeVal, titleVal, latitudeVal, longitudeVal, countryVal,
    cityVal, addresVal)
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  if not latitudeVal then
    return requiredParameterMsg .. " latitudeVal"
  end
  if not longitudeVal then
    return requiredParameterMsg .. " longitudeVal"
  end
  return luaVkApi.invokeApi("places.add", {type=typeVal, title=titleVal, latitude=latitudeVal,
      longitude=longitudeVal, country=countryVal, city=cityVal, addres=adressVal})
end

function luaVkApi.getPlacesById(placesVal)
  if not placesVal then
    return requiredParameterMsg .. " placesVal"
  end
  return luaVkApi.invokeApi("places.getById", {places=placesVal})
end

function luaVkApi.searchPlaces(query, cityId, latitudeVal, longitudeVal, radiusVal,
    offsetVal, countVal)
  if not latitudeVal then
    return requiredParameterMsg .. " latitudeVal"
  end
  if not longitudeVal then
    return requiredParameterMsg .. " longitudeVal"
  end
  return luaVkApi.invokeApi("places.search", {q=query, city=cityId, latitude=latitudeVal,
      longitude=longitudeVal, radius=radiusVal, offset=offsetVal, count=countVal})
end

function luaVkApi.checkin(placeId, textVal, latitudeVal, longitudeVal, friendsOnly,
    servicesVal)
  return luaVkApi.invokeApi("places.checkin", {place_id=placeId, text=textVal,
      latitude=latitudeVal, longitude=longitudeVal, friends_only=friendsOnly,
      services=servicesVal})
end

function luaVkApi.getCheckins(latitudeVal, longitudeVal, placeVal, userId, offsetVal,
    countVal, timestampVal, friendsOnly, needPlaces)
  return luaVkApi.invokeApi("places.getCheckins", {latitude=latitudeVal, longitude=longitudeVal,
      place=placeVal, user_id=userId, offset=offsetVal, count=countVal,
      timestamp=timestampVal, friends_only=friendsOnly, need_paces=needPlaces})
end

function luaVkApi.getPlacesTypes()
  return luaVkApi.invokeApi("places.getTypes")
end

-----------------------
--      Account      --
-----------------------
function luaVkApi.getUserCounters(fiterVal)
  return luaVkApi.invokeApi("account.getCounters", {filter=fiterVal})
end

function luaVkApi.setAccountNameInMenu(userId, nameVal)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("account.setNameInMenu", {user_id=userId, name=nameVal})
end

function luaVkApi.setAccountOnline(voipVal)
  return luaVkApi.invokeApi("account.setOnline", {voip=voipVal})
end

function luaVkApi.setAccountOffline()
  return luaVkApi.invokeApi("account.setOffline")
end

function luaVkApi.lookupAccountContacts(contactsVal, serviceVal, mycontactVal, returnAll,
    fieldsVal)
  return luaVkApi.invokeApi("account.lookupContacts", {contacts=contactsVal, service=serviceVal,
	  mycontact=mycontactVal, return_all=returnAll, fields=fieldsVal})
end

function luaVkApi.registerDevice(tokenVal, deviceModel, deviceYear, deviceId, systemVersion,
    settingsVal, sandboxVal)
  if not tokenVal then
    return requiredParameterMsg .. " tokenVal"
  end
  if not deviceId then
    return requiredParameterMsg .. " deviceId"
  end
  return luaVkApi.invokeApi("account.registerDevice", {token=tokenVal, device_model=deviceModel,
      device_year=deviceYear, device_id=deviceId, system_version=systemVersion, settings=settingsVal,
	  sandbox=sandboxVal})
end

function luaVkApi.unregisterDevice(deviceId, isSandbox)
  return luaVkApi.invokeApi("account.unregisterDevice", {device_id=deviceId, sandbox=isSandbox})
end

function luaVkApi.setSilenceMode(deviceId, timeVal, chatId, userId, soundVal)
  return luaVkApi.invokeApi("account.setSilenceMode", {device_id=deviceId, time=timeVal,
	  chat_id=chatId, user_id=userId, sound=soundVal})
end

function luaVkApi.getPushSettings(deviceId)
  return luaVkApi.invokeApi("account.getPushSettings", {device_id=deviceId})
end

function luaVkApi.setPushSettings(deviceId, settingsVal, keyStr, valueStr)
  if not deviceId then
    return requiredParameterMsg .. " deviceId"
  end
  return luaVkApi.invokeApi("account.setPushSettings", {device_id=deviceId, settings=settingsVal,
	  key=keyStr, value=valueStr})
end

function luaVkApi.getAppPermissions(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("account.getAppPermissions", {user_id=userId})
end

function luaVkApi.getActiveOffers(offsetVal, countVal)
  return luaVkApi.invokeApi("account.getActiveOffers", {offset=offsetVal, count=countVal})
end

function luaVkApi.banUser(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("account.banUser", {user_id=userId})
end

function luaVkApi.unbanUser(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("account.unbanUser", {user_id=userId})
end

function luaVkApi.getBanned(offsetVal, countVal)
  return luaVkApi.invokeApi("account.getBanned", {offset=offsetVal, count=countVal})
end

function luaVkApi.getInfo(fieldsVal)
  return luaVkApi.invokeApi("account.getInfo", {fields=fieldsVal})
end

function luaVkApi.setInfo(introVal, ownPostsDefault, noWallReplies)
  return luaVkApi.invokeApi("account.setInfo", {intro=introVal, own_posts_default=ownPostsDefault,
	  no_wall_replies=noWallReplies})
end

function luaVkApi.changePassword(restoreSid, changePasswordHash, oldPassword, newPassword)
  return luaVkApi.invokeApi("account.changePassword", {restore_sid=restoreSid,
	  change_password_hash=changePasswordHash, old_password=oldPassword, new_password=newPassword})
end

function luaVkApi.getProfileInfo()
  return luaVkApi.invokeApi("account.getProfileInfo")
end

function luaVkApi.saveProfileInfo(firstName, lastName, maidenName, screenName, cancelRequestId,
	sexVal, relationVal, relationPartnerId, bdateVal, bdateVisibility, homeTown, countryId,
	cityId, statusVal)
  return luaVkApi.invokeApi("account.saveProfileInfo", {first_name=firstName, last_name=lastName,
	  maiden_name=maidenName, screen_name=screenName, cancel_request_id=cancelRequestId,
	  sex=sexVal, relation=relationVal, relation_partner_id=relationPartnerId, bdate=bdateVal,
	  bdate_visibility=bdateVisibility, home_town=homeTown, counry_id=countryId,
	  city_id=cityId, status=statusVal})
end

-----------------------
--     Messages      --
-----------------------
function luaVkApi.getPrivateMessages(outVal, offsetVal, countVal, timeOffset, filtersVal,
    previewLength, lastMessageId)
  return luaVkApi.invokeApi("messages.get", {out=outVal, offset=offsetVal, count=countVal,
      time_offset=timeOffset, filters=filtersVal, preview_length=previewLength, 
      last_message_id=lastMessageId})
end

function luaVkApi.getDialogs(offsetVal, countVal, startMessageId, previewLength, unreadVal)
  return luaVkApi.invokeApi("messages.getDialogs", {offset=offsetVal, count=countVal,
      start_message_id=startMessageId, preview_length=previewLength, unread=unreadVal})
end

function luaVkApi.getMessagesById(messageIds, previewLength)
  if not messageIds then
    return requiredParameterMsg .. " messageIds"
  end
  return luaVkApi.invokeApi("messages.getById", {message_ids=messageIds, preview_length=previewLength})
end

function luaVkApi.searchMessages(query, previewLength, offsetVal, countVal)
  return luaVkApi.invokeApi("messages.search", {q=query, preview_length=previewLength,
      offset=offsetVal, count=countVal})
end

function luaVkApi.getMessageHistory(offsetVal, countVal, userId, chatId, peerId, startMessageId,
    revVal)
  return luaVkApi.invokeApi("messages.getHistory", {offset=offsetVal, count=countVal, user_id=userId,
      chat_id=chatId, peer_id=peerId, start_message_id, rev=revVal})
end

function luaVkApi.sendMessage(userId, peerId, domainVal, chatId, userIds, messageStr, guidVal,
    latVal, longVal, attachmentVal, forwardMessages, stickerId)
  if not messageStr or not attachmentVal then
    return requiredParameterMsg .. " messageStr or attachmentVal"
  end
  return luaVkApi.invokeApi("messages.send", {user_id=userId, peer_id=peerId, domain=domainVal,
      chat_id=chatId, user_ids=userIds, message=messageStr, guid=guidVal, lat=latVal,
      long=longVal, attachment=attachmentVal, forward_messages=forwardMessages, sticker_id=stickerId})
end

function luaVkApi.deleteMessages(messageIds)
  return luaVkApi.invokeApi("messages.delete", {message_ids=messageIds})
end

function luaVkApi.deleteDialog(userId, peerId, offsetVal, countVal)
  return luaVkApi.invokeApi("messages.deleteDialog", {user_id=userId, peer_id=peerId, offset=offsetVal,
      count=countVal})
end

function luaVkApi.restoreMessage(messageId)
  if not messageIds then
    return requiredParameterMsg .. " messageIds"
  end
  return luaVkApi.invokeApi("messages.restore", {message_id=messageId})
end

function luaVkApi.markAsRead(messageIds, peer_id, startMessageId)
  return luaVkApi.invokeApi("messages.markAsRead", {message_ids=messageIds, peer_id=peerId,
      start_message_id=startMessageId})
end

function luaVkApi.markAsImportant(messageIds, isImportant)
  return luaVkApi.invokeApi("messages.markAsImportant", {message_ids=messageIds, important=isImportant})
end

function luaVkApi.getLongPollServer(useSSL, needPts)
  return luaVkApi.invokeApi("messages.getLongPollServer", {use_ssl=useSSL, need_pts=needPts})
end

function luaVkApi.getLongPollHistory(tsVal, ptsVal, previewLength, isOnlines, fieldsVal, 
    eventsLimit, msgsLimit, maxMsgId)
  return luaVkApi.invokeApi("messages.getLongPollHistory", {ts=tsVal, pts=ptsVal, 
      preview_length=previewLength, onlines=isOnlines, fields=fieldsVal, events_limit=eventsLimit,
      msgs_limit=msgsLimit, max_msg_id=maxMsgId})
end

function luaVkApi.getChat(chatId, chatIds, fieldsVal, nameCase)
  return luaVkApi.invokeApi("messages.getChat", {chat_id=chatId, chat_ids=chatIds, fields=fieldsVal,
      name_case=nameCase})
end

function luaVkApi.createChat(userIds, titleVal)
  if not userIds then
    return requiredParameterMsg .. " userIds"
  end
  return luaVkApi.invokeApi("messages.createChat", {user_ids=userIds, title=titleVal})
end

function luaVkApi.editChat(chatId, titleVal)
  if not chatId then
    return requiredParameterMsg .. " chatId"
  end
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("messages.editChat", {chat_id=chatId, title=titleVal})
end

function luaVkApi.getChatUsers(chatId, chatIds, fieldsVal, nameCase)
  return luaVkApi.invokeApi("messages.getChatUsers", {chat_id=chatId, chat_ids=chatIds,
      fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.setActivity(userId, typeVal, peerId)
  return luaVkApi.invokeApi("messages.setActivity", {user_id=userId, type=typeVal,
      peer_id=peerId})
end

function luaVkApi.searchDialogs(query, limitVal, fieldsVal)
  return luaVkApi.invokeApi("messages.searchDialogs", {q=query, limit=limitVal,
      fields=fieldsVal})
end

function luaVkApi.addChatUser(chatId, userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("messages.addChatUser", {chat_id=chatId, user_id=userId})
end

function luaVkApi.removeChatUser(chatId, userId)
  if not chatId then
    return requiredParameterMsg .. " chatId"
  end
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("messages.removeChatUser", {chat_id=chatId, user_id=userId})
end

function luaVkApi.getLastActivity(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("messages.getLastActivity", {user_id=userId})
end

function luaVkApi.setChatPhoto(fileVal)
  if not fileVal then
    return requiredParameterMsg .. " fileVal"
  end
  return luaVkApi.invokeApi("messages.setChatPhoto", {file=fileVal})
end

function luaVkApi.deleteChatPhoto(chatId)
  if not chatId then
    return requiredParameterMsg .. " chatId"
  end
  return luaVkApi.invokeApi("messages.deleteChatPhoto", {chat_id=chatId})
end

-----------------------
--      News         --
-----------------------
function luaVkApi.getNewsFeed(filtersVal, returnBanned, startTime, endTime, maxPhotos,
    sourceIds, startFrom, countVal, fieldsVal)
  return luaVkApi.invokeApi("newsfeed.get", {filters=filtersVal, return_banned=returnBanned, 
      start_time=startTime, end_time=endTime, max_photos=maxPhotos, source_ids=sourceIds, 
      start_from=startFrom, count=countVal, fields=fieldsVal})
end

function luaVkApi.getRecommendedNews(startTime, endTime, maxPhotos, startFrom, countVal,
    fieldsVal)
  return luaVkApi.invokeApi("newsfeed.getRecommended", {start_time=startTime, end_time=endTime,
      max_photos=maxPhotos, start_from=startFrom, count=countVal, fields=fieldsVal})
end

function luaVkApi.getNewsComments(countVal, filtersVal, repostsVal, startTime, endTime, 
    lastCommentsCount, startFrom, fieldsVal)
  return luaVkApi.invokeApi("newsfeed.getComments", {count=countVal, filters=filtersVal,
      reposts=repostsVal, start_time=startTime, end_time=endTime,
      last_comments_count=lastCommentsCount, start_from=startFrom, fields=fieldsVal})
end

function luaVkApi.getUserMentions(ownerId, startTime, endTime, offsetVal, countVal)
  return luaVkApi.invokeApi("newsfeed.getMentions", {owner_id=ownerId, start_time=startTime,
      end_time=endTime, offset=offsetVal, count=countVal})
end

function luaVkApi.getBanned(isExtended, fieldsVal, nameCase)
  return luaVkApi.invokeApi("newsfeed.getBanned", {extended=isExtended, fields=fieldsVal,
      name_case=nameCase})
end

function luaVkApi.addBan(userIds, groupIds)
  return luaVkApi.invokeApi("newsfeed.addBan", {user_ids=userIds, group_ids=userIds})
end 

function luaVkApi.deleteBan(userIds, groupIds)
  return luaVkApi.invokeApi("newsfeed.deleteBan", {user_ids=userIds, group_ids=userIds})
end 

function luaVkApi.ignoreItem(typeVal, ownerId, itemId)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not itemId then
    return requiredParameterMsg .. " itemId"
  end
  return luaVkApi.invokeApi("newsfeed.ignoreItem", {type=typeVal, ownner_id=ownerId,
      item_id=itemId})
end 

function luaVkApi.unignoreItem(typeVal, ownerId, itemId)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not itemId then
    return requiredParameterMsg .. " itemId"
  end
  return luaVkApi.invokeApi("newsfeed.unignoreItem", {type=typeVal, ownner_id=ownerId,
      item_id=itemId})
end 

function luaVkApi.searchNews(keyWord, isExtended, countVal, latitudeVal, longitudeVal,
    startTime, endTime, startFrom, fieldsVal)
  return luaVkApi.invokeApi("newsfeed.search", {q=keyWord, extended=isExtended, count=countVal,
      latitude-latitudeVal, longitude=longitudeVal, start_time=startTime, endTime=endTime, 
      start_from=startFrom, fields=fieldsVal})
end

function luaVkApi.getLists(listIds, isExtended)
  return luaVkApi.invokeApi("newsfeed.getLists", {list_ids=listIds, extended=isExtended})
end

function luaVkApi.saveList(listId, titleVal, sourceIds, noReposts)
  if not titleVal then
    return requiredParameterMsg .. " titleVal"
  end
  return luaVkApi.invokeApi("newsfeed.saveList", {list_id=listId, title=titleVal, 
  source_ids=sourceIds, no_reposts=noReposts})
end 

function luaVkApi.deleteList(listId)
  if not listId then
    return requiredParameterMsg .. " listId"
  end
  return luaVkApi.invokeApi("newsfeed.deleteList", {list_id=listId})
end

function luaVkApi.unsubscribe(typeVal, ownerId, itemId)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  if not itemId then
    return requiredParameterMsg .. " itemId"
  end
  return luaVkApi.invokeApi("newsfeed.unsubscribe", {type=typeVal, owner_id=ownerId,
      item_id=itemId})
end

function luaVkApi.getSuggestedSources(offsetVal, countVal, shuffleVal, fieldsVal)
  return luaVkApi.invokeApi("newsfeed.getSuggestedSources", {offset=offsetVal, count=countVal,
      shuffle=shuffleVal, fieldsVal})
end

-----------------------
--      Likes        --
-----------------------
function luaVkApi.getLikerIds(typeVal, ownerId, itemId, pageUrl, filterVal,
    friendsOnly, isExtended, offsetVal, countVal, skipOwn)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  return luaVkApi.invokeApi("likes.getList", {type=typeVal, owner_id=ownerId,
      item_id=itemId, page_url=pageUrl, filter=filterVal, friends_only=friendsOnly,
      extended=isExtended, offset=offsetVal, count=countVal, skip_own=skipOwn})
end

function luaVkApi.putLike(entityType, ownerId, itemId, accessKey, refStr)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  if not itemId then
    return requiredParameterMsg .. " itemId"
  end
  return luaVkApi.invokeApi("likes.add", {type=entityType, owner_id=ownerId,
      item_id=itemId, access_key=accessKey, ref=refStr})
end

function luaVkApi.deleteLike(entityType, ownerId, itemId)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  if not itemId then
    return requiredParameterMsg .. " itemId"
  end
  return luaVkApi.invokeApi("likes.delete", {type=entityType, owner_id=ownerId,
      item_id=itemId})
end

function luaVkApi.isLiked(userId, entityType, ownerId, itemId)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  if not itemId then
    return requiredParameterMsg .. " itemId"
  end
  return luaVkApi.invokeApi("likes.isLiked", {user_id=userId, type=entityType,
      owner_id=ownerId, item_id=itemId})
end

-----------------------
--      Polls        --
-----------------------
function luaVkApi.getPollById(ownerId, isBoard, pollId)
  if not pollId then
    return requiredParameterMsg .. " pollId"
  end
  return luaVkApi.invokeApi("polls.getById", {owner_id=ownerId, is_board=isBoard, 
      poll_id=pollId})
end

function luaVkApi.addVote(ownerId, pollId, answerId, isBoard)
  if not pollId then
    return requiredParameterMsg .. " pollId"
  end
  if not answerId then
    return requiredParameterMsg .. " answerId"
  end
  return luaVkApi.invokeApi("polls.addVote", {owner_id=ownerId, poll_id=pollId, 
      answer_id=answerId, is_board=isBoard})
end

function luaVkApi.deleteVote(ownerId, pollId, answerId, isBoard)
  if not pollId then
    return requiredParameterMsg .. " pollId"
  end
  if not answerId then
    return requiredParameterMsg .. " answerId"
  end
  return luaVkApi.invokeApi("polls.deleteVote", {owner_id=ownerId, poll_id=pollId, 
      answer_id=answerId, is_board=isBoard})
end

function luaVkApi.getVoters(ownerId, pollId, answerIds, isBoard, friendsOnly, offsetVal,
    countVal, fieldsVal, nameCase)
  if not pollId then
    return requiredParameterMsg .. " pollId"
  end
  if not answerIds then
    return requiredParameterMsg .. " answerIds"
  end
  return luaVkApi.invokeApi("polls.getVoters", {owner_id=ownerId, poll_id=pollId, 
      answer_ids=answerIds, is_board=isBoard, friends_only=friendsOnly, offset=offsetVal,
      count=countVal, fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.createPoll(questionStr, isAnonymous, ownerId, addAnswers)
  return luaVkApi.invokeApi("polls.create", {question=questionStr, is_anonymous=isAnonymous, 
      owner_id=ownerId, add_answers=addAnswers})
end

function luaVkApi.editPoll(ownerId, pollId, questionStr, addAnswers, editAnswers, 
    deleteAnswers)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not pollId then
    return requiredParameterMsg .. " pollId"
  end
  return luaVkApi.invokeApi("polls.edit", {owner_id=ownerId, poll_id=pollId,
      question=questionStr, question=questionStr, add_answers=addAnswers,
      edit_answers=editAnswers, delete_answers=deleteAnswers})
end

-----------------------
--    Documents      --
-----------------------
function luaVkApi.getDocuments(countVal, offsetVal, ownerId)
  return luaVkApi.invokeApi("docs.get", {count=countVal, offset=offsetId, owner_id=ownerId})
end

function luaVkApi.getDocumentsById(docsVal)
  if not docsVal then
    return requiredParameterMsg .. " docsVal"
  end
  return luaVkApi.invokeApi("docs.getById", {docs=docsVal})
end

function luaVkApi.getUploadServer(groupId)
  return luaVkApi.invokeApi("docs.getUploadServer", {group_id=groupId})
end

function luaVkApi.getWallUploadServer(groupId)
  return luaVkApi.invokeApi("docs.getWallUploadServer", {group_id=groupId})
end

function luaVkApi.saveDoc(docFile, titleVal, tagsVal)
  if not docFile then
    return requiredParameterMsg .. " docFile"
  end
  return luaVkApi.invokeApi("docs.save", {file=docFile, title=titleVal, tags=tagsVal})
end

function luaVkApi.deleteDoc(ownerId, docId)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not docId then
    return requiredParameterMsg .. " docId"
  end
  return luaVkApi.invokeApi("docs.delete", {owner_id=ownerId, doc_id=docId})
end

function luaVkApi.addDoc(ownerId, docId, accessKey)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not docId then
    return requiredParameterMsg .. " docId"
  end
  return luaVkApi.invokeApi("docs.add", {owner_id=ownerId, doc_id=docId, access_key=accessKey})
end

-----------------------
--    Favorites      --
-----------------------
function luaVkApi.getBookmarkers(offsetVal, countVal)
  return luaVkApi.invokeApi("fave.getUsers", {offset=offsetVal, count=countVal})
end

function luaVkApi.getLikedPhotos(offsetVal, countVal, photoSizes)
  return luaVkApi.invokeApi("fave.getPhotos", {offset=offsetVal, count=countVal,
      photo_sizes=photoSizes})
end

function luaVkApi.getLikedPosts(offsetVal, countVal, isExtended)
  return luaVkApi.invokeApi("fave.getPosts", {offset=offsetVal, count=countVal,
      extended=isExtended})
end

function luaVkApi.getLikedVideos(offsetVal, countVal, isExtended)
  return luaVkApi.invokeApi("fave.getVideos", {offset=offsetVal, count=countVal,
      extended=isExtended})
end

function luaVkApi.getLikedLinks(offsetVal, countVal)
  return luaVkApi.invokeApi("fave.getLinks", {offset=offsetVal, count=countVal})
end

function luaVkApi.bookmarkUser(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("fave.addUser", {user_id=userId})
end

function luaVkApi.removeBookmarkedUser(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("fave.removeUser", {user_id=userId})
end

function luaVkApi.bookmarkGroup(groupId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("fave.addGroup", {group_id=groupId})
end

function luaVkApi.removeBookmarkedGroup(groupId)
  if not groupId then
    return requiredParameterMsg .. " groupId"
  end
  return luaVkApi.invokeApi("fave.removeGroup", {group_id=groupId})
end

function luaVkApi.bookmarkLink(linkStr, textStr)
  if not linkStr then
    return requiredParameterMsg .. " linkStr"
  end
  return luaVkApi.invokeApi("fave.addLink", {link=linkStr, text=textStr})
end

function luaVkApi.removeBookmarkedLink(linkId)
  if not linkId then
    return requiredParameterMsg .. " linkId"
  end
  return luaVkApi.invokeApi("fave.removeLink", {link_id=linkId})
end

-----------------------
--   Notifications   --
-----------------------
function luaVkApi.getNotifications(countVal, startFrom, filtersVal, startTime, endTime)
  return luaVkApi.invokeApi("notifications.get", {count=countVal, start_from=startFrom,
      filters=filtersVal, start_time=startTime, end_time=endTime})
end

function luaVkApi.markNotificationsAsViewed()
  return luaVkApi.invokeApi("notifications.markAsViewed")
end

-----------------------
--       Stats       --
-----------------------
function luaVkApi.getStatistics(groupId, appId, dateFrom, dateTo)
  return luaVkApi.invokeApi("stats.get", {group_id=groupId, app_id=appId, date_from=dateFrom,
      date_to=dateTo})
end

function luaVkApi.trackVisitor()
  return luaVkApi.invokeApi("stats.trackVisitor")
end

function luaVkApi.trackVisitor(ownerId, postId)
  if not ownerId then
    return requiredParameterMsg .. " ownerId"
  end
  if not postId then
    return requiredParameterMsg .. " postId"
  end
  return luaVkApi.invokeApi("stats.getPostReach", {owner_id=ownerId, post_id=postId})
end

-----------------------
--      Search       --
-----------------------
function luaVkApi.getHint(query, limitVal, filtersVal, searchGlobal)
  return luaVkApi.invokeApi("search.getHints", {q=query, limit=limitVal, filters=filtersVal,
      search_global=searchGlobal})
end

-----------------------
--       Apps        --
-----------------------
function luaVkApi.getAppsCatalog(sortVal, offsetVal, countVal, platformVal, isExtended,
    returnFriends, fieldsVal, nameCase, query, genreId, filterVal)
  if not countVal then
    return requiredParameterMsg .. " countVal"
  end
  return luaVkApi.invokeApi("apps.getCatalog", {sort=sortVal, offset=offsetVal, count=countVal,
      platform=platformVal, extended=isExtended, return_friends=returnFriends, fields=fieldsVal, 
      name_case=nameCase, q=query, genre_id=genreId, filter=filterVal})
end

function luaVkApi.getApp(appId, appIds, platformVal, isExtended, returnFriends, fieldsVal,
    nameCase)
  return luaVkApi.invokeApi("apps.get", {app_id=appId, app_ids=appIds, platform=platformVal,
      extended=isExtended, return_friends=returnFriends, fields=fieldsVal, name_case=nameCase})
end

function luaVkApi.sendAppRequest(userId, textVal, typeVal, nameVal, keyVal, separateVal)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("apps.sendRequest", {user_id, text=textVal, type=typeVal, name=nameVal,
      key=keyVal, separate=separateVal})
end

function luaVkApi.deleteAppRequests()
  return luaVkApi.invokeApi("apps.deleteAppRequests")
end

function luaVkApi.getFriendsList(isExtended, countVal, offsetVal, typeVal, fieldsVal)
  return luaVkApi.invokeApi("apps.getFriendsList", {extended=isExtended, count=countVal, 
      offset=offsetVal, type=typeVal, fields=fieldsVal})
end

function luaVkApi.getLeaderboard(typeVal, globalVal, isExtended)
  if not typeVal then
    return requiredParameterMsg .. " typeVal"
  end
  return luaVkApi.invokeApi("apps.getLeaderboard", {type=typeVal, global=globalVal, 
      extended=isExtended})
end

function luaVkApi.getScore(userId)
  if not userId then
    return requiredParameterMsg .. " userId"
  end
  return luaVkApi.invokeApi("apps.getScore", {user_id=userId})
end

-----------------------
--     Service       --
-----------------------
function luaVkApi.checkLink(urlStr)
  if not urlStr then
    return requiredParameterMsg .. " urlStr"
  end
  return luaVkApi.invokeApi("utils.checkLink", {url=urlStr})
end

function luaVkApi.resolveScreenName(screenNsme)
  if not screenNsme then
    return requiredParameterMsg .. " screenNsme"
  end
  return luaVkApi.invokeApi("utils.resolveScreenName", {screen_name=screenNsme})
end

function luaVkApi.getServerTime()
  return luaVkApi.invokeApi("utils.getServerTime")
end

-----------------------
--     VK data       --
-----------------------
function luaVkApi.getCountries(needAll, codeStr, offsetVal, countVal)
  return luaVkApi.invokeApi("database.getCountries", {need_all=needAll, code=codeStr,
      offset=offsetVal, count=countVal})
end

function luaVkApi.getRegions(countryId, query, offsetVal, countVal)
  if not countryId then
    return requiredParameterMsg .. " countryId"
  end
  return luaVkApi.invokeApi("database.getRegions", {country_id=countryId, q=query,
      offset=offsetVal, count=countVal})
end

function luaVkApi.getStreetsById(streetIds)
  if not streetIds then
    return requiredParameterMsg .. " streetIds"
  end
  return luaVkApi.invokeApi("database.getStreetsById", {street_ids=streetIds})
end

function luaVkApi.getCountriesById(countryIds)
  return luaVkApi.invokeApi("database.getCountriesById", {country_ids=countryIds})
end

function luaVkApi.getCities(countryId, regionId, query, needAll, offsetVal, countVal)
  if not countryId then
    return requiredParameterMsg .. " countryId"
  end
  return luaVkApi.invokeApi("database.getCities", {country_id=countryId, region_id=regionId,
      q=query, need_all=needAll, offset=offsetVal, count=countVal})
end

function luaVkApi.getCitiesById(cityIds)
  return luaVkApi.invokeApi("database.getCitiesById", {city_ids=cityIds})
end

function luaVkApi.getUniversities(query, countryId, cityId, offsetVal, countVal)
  return luaVkApi.invokeApi("database.getUniversities", {q=query, country_id=countryId, 
      city_id=cityId, offset=offsetVal, count=countVal})
end

function luaVkApi.getSchools(query, cityId, offsetVal, countVal)
  if not cityId then
    return requiredParameterMsg .. " cityId"
  end
  return luaVkApi.invokeApi("database.getSchools", {q=query, city_id=cityId, offset=offsetVal,
      count=countVal})
end

function luaVkApi.getSchoolClasses(countryId)
  return luaVkApi.invokeApi("database.getSchoolClasses", {country_id=countryId})
end

function luaVkApi.getFaculties(universityId, offsetVal, countVal)
  if not universityId then
    return requiredParameterMsg .. " universityId"
  end
  return luaVkApi.invokeApi("database.getFaculties", {university_id=universityId, offset=offsetVal,
      count=countVal})
end

function luaVkApi.getChairs(facultyId, offsetVal, countVal)
  if not facultyId then
    return requiredParameterMsg .. " facultyId"
  end
  return luaVkApi.invokeApi("database.getChairs", {faculty_id=facultyId, offset=offsetVal,
      count=countVal})
end

-----------------------
--      Gifts        --
-----------------------
function luaVkApi.getGifts(userId, countVal, offsetVal)
  return luaVkApi.invokeApi("gifts.get", {user_id=userId, count=countVal, offset=offsetVal})
end

-----------------------
--      Other        --
-----------------------
function luaVkApi.executeCode(codeStr)
  return luaVkApi.invokeApi("execute", {code=codeStr})
end



return luaVkApi
