package com.pixelwall.service;

import com.pixelwall.entity.user.OauthProvider;
import com.pixelwall.entity.user.User;

import java.util.Optional;

public interface UserService {

    Optional<User> getUserById(Integer id);

    Optional<User> getUserByDisplayName(String displayName);

    Optional<User> getUserByEmail(String email);

    Optional<User> getUserByUuid(String uuid);

    Optional<User> getUserByOauth(OauthProvider provider, String oauthId);

    User createUser(User user);

    User updateUser(User user);

    void deleteUserById(Integer id);
}
