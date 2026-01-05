package com.pixelwall.service.implementation;

import com.pixelwall.entity.user.OauthProvider;
import com.pixelwall.entity.user.User;
import com.pixelwall.repository.UserRepository;
import com.pixelwall.service.UserService;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    @Override
    public Optional<User> getUserByEmail(String email) {
        return Optional.ofNullable(userRepository.findByEmail(email));
    }

    @Override
    public Optional<User> getUserByUuid(String uuid) {
        return Optional.ofNullable(userRepository.findByUuid(uuid));
    }

    @Override
    public Optional<User> getUserByOauth(OauthProvider provider, String oauthId) {
        return Optional.ofNullable(userRepository.findByOauthProviderAndOauthId(provider, oauthId));
    }

    @Override
    public User createUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public User updateUser(User user) {
        return userRepository.save(user);
    }

    @Override
    public void deleteUserById(Long id) {
        userRepository.deleteById(id);
    }
}
