import 'package:flutter_test/flutter_test.dart';
import 'package:sportiva_app/features/membership/data/membership_models.dart';

Map<String, dynamic> requestJson(String status, List<Map<String, dynamic>> media) => {
  'id': 'r1',
  'status': status,
  'clubName': 'Club',
  'governorateName': 'Gharbia',
  'city': 'Tanta',
  'address': 'Street 1',
  'phone': '01012345678',
  'rejectionReason': status == 'Rejected' ? 'Photos are unclear' : null,
  'media': media,
};

void main() {
  test('a request reads its status and keeps the rejection reason', () {
    final rejected = MembershipRequest.fromJson(requestJson('Rejected', const []));
    expect(rejected.status, MembershipStatus.rejected);
    expect(rejected.rejectionReason, 'Photos are unclear');
    expect(MembershipRequest.fromJson(requestJson('Approved', const [])).status, MembershipStatus.approved);
    expect(MembershipRequest.fromJson(requestJson('Pending', const [])).status, MembershipStatus.pending);
  });

  test('media that is not ready or failed is still processing', () {
    final request = MembershipRequest.fromJson(
      requestJson('Pending', [
        {'id': 'a', 'type': 'Image', 'status': 'Ready', 'url': 'https://x/a.jpg'},
        {'id': 'b', 'type': 'Video', 'status': 'Processing'},
        {'id': 'c', 'type': 'Image', 'status': 'Failed'},
      ]),
    );
    expect(request.media.map((m) => (m.isReady, m.isFailed, m.isVideo)), [
      (true, false, false),
      (false, false, true),
      (false, true, false),
    ]);
    expect(request.hasProcessingMedia, isTrue);
    expect(
      MembershipRequest.fromJson(
        requestJson('Pending', [
          {'id': 'a', 'type': 'Image', 'status': 'Ready'},
        ]),
      ).hasProcessingMedia,
      isFalse,
    );
  });
}
