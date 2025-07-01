import 'goal_zone_game.dart';

extension SideProps on Side {
  bool get isHorizontal => this == Side.top || this == Side.bottom;
}
