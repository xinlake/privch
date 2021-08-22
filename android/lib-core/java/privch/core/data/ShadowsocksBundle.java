package privch.core.data;

import androidx.room.Embedded;
import androidx.room.Relation;

import java.util.List;

public class ShadowsocksBundle {
    @Embedded
    public Shadowsocks shadowsocks;

    @Relation(
        parentColumn = "id",
        entityColumn = "serverId"
    )
    public List<Statistic> statisticsList;
}
