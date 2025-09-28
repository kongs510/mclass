package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.demo.entity.Member;
import com.example.demo.repository.MemberRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberService {
        private final MemberRepository memberRepository;
    public Member save(Member member) { return memberRepository.save(member); }
    public List<Member> findAll() { return memberRepository.findAll(); }
}
